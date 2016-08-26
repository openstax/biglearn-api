class BackgroundTasks::ResponseBundler
  def initialize(bundle_response_limit:,
                 bundle_age_limit:,
                 process_response_limit:,
                 partition_count:,
                 partition_modulo:)
    @bundle_response_limit  = bundle_response_limit
    @bundle_age_limit       = bundle_age_limit
    @process_response_limit = process_response_limit
    @partition_count        = partition_count
    @partition_modulo       = partition_modulo
  end

  def process
    ResponseBundle.transaction(isolation: :serializable) do
      ##
      ## Collect the target unbundled Responses to be processed.
      ##

      sql_unbundled_responses = %Q{
        SELECT * FROM (
          SELECT * FROM responses
          WHERE NOT EXISTS (
            SELECT response_uuid FROM response_bundle_entries rbe
            WHERE rbe.response_uuid = responses.response_uuid
          )
        ) AS target_response_uuids
        WHERE target_response_uuids.partition_value % #{partition_count} = #{partition_modulo}
        ORDER BY target_response_uuids.created_at ASC
        LIMIT #{process_response_limit}
      }.gsub(/\n\s*/, ' ')

      unbundled_responses = Response.find_by_sql(sql_unbundled_responses)

      ##
      ## Add as many unbundled Responses as possible to existing
      ## open target ResponseBundles.
      ##

      sql_open_response_bundles = %Q{
        SELECT * FROM response_bundles
        WHERE is_open IS TRUE
        AND partition_value % #{partition_count} = #{partition_modulo}
      }.gsub(/\n\s*/, ' ')

      open_response_bundles = ResponseBundle.find_by_sql(sql_open_response_bundles)

      open_response_bundles.each do |response_bundle|
        num_bundle_responses = ResponseBundleEntry.where{response_bundle_uuid == response_bundle.response_bundle_uuid}
                                                  .count

        num_open_slots   = bundle_response_limit - num_bundle_responses
        responses_to_add = unbundled_responses.shift(num_open_slots)

        responses_to_add.each do |response|
          ResponseBundleEntry.create!(
            response_bundle_uuid: response_bundle.response_bundle_uuid,
            response_uuid:        response.response_uuid,
          )
        end

        if responses_to_add.count == num_open_slots
          response_bundle.is_open = false
          response_bundle.save!
        end
      end

      ##
      ## Add any remaining unbundled Responses to new ResponseBundles.
      ##

      unbundled_responses.each_slice(bundle_response_limit) do |responses|
        is_open = (responses.count < bundle_response_limit)

        response_bundle = ResponseBundle.create!(
          response_bundle_uuid: SecureRandom.uuid.to_s,
          is_open:              is_open,
          partition_value:      rand(1000),
        )

        responses.each do |response|
          ResponseBundleEntry.create!(
            response_bundle_uuid: response_bundle.response_bundle_uuid,
            response_uuid:        response.response_uuid,
          )
        end
      end

      ##
      ## Close any "old" target ResponseBundles.
      ##

      old_response_bundles = ResponseBundle.find_by_sql(sql_open_response_bundles)
                                           .select{|bundle| bundle.created_at <= Time.now - bundle_age_limit}
                                           .to_a

      old_response_bundles.each do |response_bundle|
        response_bundle.is_open = false
        response_bundle.save!
      end
    end
  end

  protected

  attr_reader :bundle_response_limit
  attr_reader :bundle_age_limit
  attr_reader :process_response_limit
  attr_reader :partition_count
  attr_reader :partition_modulo
end
