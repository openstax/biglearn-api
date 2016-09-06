class OpenStax::BundleManager::Manager

  def initialize(model:)
    @model                            = model
    @model_table                      = model.table_name
    @bundle_model                     = ('Bundle::' + model.name).constantize
    @bundle_model_table               = @bundle_model.table_name
    @bundle_bundle_model              = ('Bundle::' + model.name + 'Bundle').constantize
    @bundle_bundle_model_table        = @bundle_bundle_model.table_name
    @bundle_entry_model               = ('Bundle::' + model.name + 'Entry').constantize
    @bundle_entry_model_table         = @bundle_entry_model.table_name
    @bundle_confirmation_model        = ('Bundle::' + model.name + 'Confirmation').constantize
    @bundle_confirmation_model_table  = @bundle_confirmation_model.table_name
  end

  def partition(max_records_to_process:)
    ##
    ## Find the Model records without corresponding
    ## Bundle::Model records.
    ##

    sql_target_records = %Q{
      SELECT * FROM (
        SELECT * FROM #{model_table} mt
        WHERE NOT EXISTS (
          SELECT uuid FROM #{bundle_model_table} bmt
          WHERE bmt.uuid = mt.uuid
        )
      ) AS target_models
      ORDER BY target_models.created_at ASC
      LIMIT #{max_records_to_process}
    }.gsub(/\n\s*/, ' ')
    target_records = model.find_by_sql(sql_target_records)

    ##
    ## Upsert a Bundle::Model record for each target Model record.
    ##

    bundle_records = target_records.map{ |record|
      bundle_model.new(
        uuid:            record.uuid,
        partition_value: Kernel::rand(10000),
      )
    }

    bundle_model.import bundle_records, on_duplicate_key_ignore: true

    self
  end


  def bundle(max_records_to_process:,
             max_records_per_bundle:,
             max_age_per_bundle:,
             partition_count:,
             partition_modulo:)
    num_processed_records = 0

    loop do
      break if num_processed_records >= max_records_to_process

      target_records = bundle_model.find_each.select{ |record|
        record.partition_value % partition_count == partition_modulo
      }.select{ |record|
        bundle_entry_model.where{uuid == record.uuid}.none?
      }.sort_by{ |record|
        record.created_at
      }.take([max_records_per_bundle, max_records_to_process - num_processed_records].min)

      break if target_records.none?

      break if (target_records.count < max_records_per_bundle) &&
               (Time.now - target_records.map(&:created_at).min < max_age_per_bundle)

      bundle = bundle_bundle_model.create!(
        uuid:             SecureRandom.uuid.to_s,
        partition_value:  Kernel::rand(10000)
      )

      target_records.map do |record|
        bundle_entry_model.create!(
          uuid:        record.uuid,
          bundle_uuid: bundle.uuid,
        )
      end

      num_processed_records += target_records.count
    end
  end

  def confirm(receiver_uuid:,
              bundle_uuids_to_confirm:)
    return [] if bundle_uuids_to_confirm.empty?

    ##
    ## Find all Bundles in bundle_uuids_to_confirm that:
    ##   - actually exist
    ##   - don't already have Confirmation records.
    ##

    bundle_uuid_str = bundle_uuids_to_confirm.map{ |uuid|
      "'#{uuid}'"
    }.join(',')

    sql_newly_confirmed_bundle_uuids = %Q{
      SELECT uuid FROM (
        SELECT * FROM #{bundle_bundle_model_table} bbmt
        WHERE NOT EXISTS (
          SELECT bundle_uuid FROM #{bundle_confirmation_model_table} bcmt
          WHERE bcmt.receiver_uuid = '#{receiver_uuid}'
          AND bbmt.uuid = bcmt.bundle_uuid
        )
      ) AS unconfirmed
      WHERE unconfirmed.uuid IN (#{bundle_uuid_str})
    }.gsub(/\n\s*/, ' ')

    newly_confirmed_bundle_uuids = bundle_model.connection.execute(sql_newly_confirmed_bundle_uuids)
                                               .map{|hash| hash.fetch('uuid')}

    ##
    ## Create the new Confirmations and UPSERT them.
    ##

    new_confirmations = newly_confirmed_bundle_uuids.map do |bundle_uuid|
      bundle_confirmation_model.new(
        bundle_uuid:   bundle_uuid,
        receiver_uuid: receiver_uuid,
      )
    end

    bundle_confirmation_model.import new_confirmations, on_duplicate_key_ignore: true

    ##
    ## Retrieve a list of Bundle uuids with Confirmations
    ## matching uuids in bundle_uuids_to_confirm.
    ##

    sql_confirmed_bundle_uuids = %Q{
      SELECT bundle_uuid FROM #{bundle_confirmation_model_table}
      WHERE receiver_uuid = '#{receiver_uuid}'
      AND bundle_uuid IN (#{bundle_uuid_str})
    }.gsub(/\n\s*/, ' ')

    confirmed_bundle_uuids = bundle_model.connection.execute(sql_confirmed_bundle_uuids)
                                         .map{|hash| hash.fetch('bundle_uuid')}

    confirmed_bundle_uuids
  end

  def fetch(goal_records_to_return:,
            max_bundles_to_process:,
            receiver_uuid:,
            partition_count:,
            partition_modulo:)
    ##
    ## Find all Bundle::ModelBundle uuids that have not yet been
    ## confirmed by this receiver that also belong to the partition.
    ##

    sql_bundle_uuids = %Q{
      SELECT uuid FROM (
        SELECT * FROM #{bundle_bundle_model_table} bbmt
        WHERE NOT EXISTS (
          SELECT bundle_uuid FROM #{bundle_confirmation_model_table} bcmt
          WHERE bcmt.receiver_uuid = '#{receiver_uuid}'
          AND bbmt.uuid = bcmt.bundle_uuid
        )
      ) AS unconfirmed
      WHERE unconfirmed.partition_value % #{partition_count} = #{partition_modulo}
      ORDER BY unconfirmed.created_at ASC
      LIMIT #{max_bundles_to_process}
    }.gsub(/\n\s*/, ' ')

    bundle_uuids = bundle_model.connection.execute(sql_bundle_uuids)
                               .map{|hash| hash.fetch('uuid')}

    ##
    ## Get the Model uuids for the target bundles.
    ##

    model_uuids = bundle_entry_model.where{bundle_uuid.in bundle_uuids}
                                    .map(&:uuid)

    ##
    ## If the number of Model uuids is less than the goal and
    ## we haven't reached our processing limit, return additional
    ## unbundled Model uuids in creation order.
    ##

    if (bundle_uuids.count < max_bundles_to_process) && (model_uuids.count < goal_records_to_return)
      sql_unbundled_model_uuids = %Q{
        SELECT uuid FROM (
          SELECT * FROM #{bundle_model_table} bmt
          WHERE NOT EXISTS (
            SELECT uuid FROM #{bundle_entry_model_table} bemt
            WHERE bemt.uuid = bmt.uuid
          )
        ) AS unbundled
        WHERE unbundled.partition_value % #{partition_count} = #{partition_modulo}
        ORDER BY unbundled.created_at ASC
        LIMIT #{goal_records_to_return - model_uuids.count}
      }.gsub(/\n\s*/, ' ')

      extra_model_uuids = bundle_model.connection.execute(sql_unbundled_model_uuids)
                                      .map{|hash| hash.fetch('uuid')}

      model_uuids += extra_model_uuids
    end

    { bundle_uuids: bundle_uuids,
      model_uuids:  model_uuids,  }
  end

  protected

  attr_reader :model
  attr_reader :model_table
  attr_reader :bundle_model
  attr_reader :bundle_model_table
  attr_reader :bundle_bundle_model
  attr_reader :bundle_bundle_model_table
  attr_reader :bundle_entry_model
  attr_reader :bundle_entry_model_table
  attr_reader :bundle_confirmation_model
  attr_reader :bundle_confirmation_model_table
end

  # def _fetch_response_bundles(max_bundles_to_return:,
  #                             confirmed_bundle_uuids:,
  #                             receiver_uuid:,
  #                             partition_count:,
  #                             partition_modulo:)
  #   response_data, bundle_uuids, response_confirmed_bundle_uuids = ResponseBundle.transaction(isolation: :serializable) do
  #     response_confirmed_bundle_uuids = _create_confirmations(
  #       receiver_uuid:          receiver_uuid,
  #       confirmed_bundle_uuids: confirmed_bundle_uuids
  #     )

  #     bundle_uuids, response_data = _get_bundles(
  #       max_bundles_to_return: max_bundles_to_return,
  #       receiver_uuid:         receiver_uuid,
  #       partition_count:       partition_count,
  #       partition_modulo:      partition_modulo
  #     )

  #     _create_receipts(
  #       bundle_uuids:  bundle_uuids,
  #       receiver_uuid: receiver_uuid
  #     )

  #     [response_data, bundle_uuids, response_confirmed_bundle_uuids]
  #   end

  #   [response_data, bundle_uuids, response_confirmed_bundle_uuids]
  # end


  # def _create_confirmations(receiver_uuid:, confirmed_bundle_uuids:)
  #   return [] if confirmed_bundle_uuids.empty?

  #   ##
  #   ## Collect only the uuids of ResponseBundles that:
  #   ##   - already exist
  #   ##   - are sent
  #   ##   - are closed
  #   ##

  #   uuid_str = confirmed_bundle_uuids.map{|uuid| "'#{uuid}'"}
  #                                    .join(',')

  #   sql_valid_confirmed_bundle_uuids = %Q{
  #     SELECT uuid FROM response_bundles
  #     INNER JOIN response_bundle_receipts ON response_bundles.uuid = response_bundle_receipts.response_bundle_uuid
  #     WHERE response_bundles.is_open IS FALSE
  #     AND uuid IN (#{uuid_str})
  #   }.gsub(/\n\s*/, ' ')

  #   valid_confirmed_bundle_uuids =
  #     ResponseBundle.connection.execute(sql_valid_confirmed_bundle_uuids)
  #                   .map{|hash| hash['uuid']}

  #   return [] if valid_confirmed_bundle_uuids.empty?

  #   ##
  #   ## Create the SQL value string.
  #   ##

  #   start_time     = Time.now
  #   start_time_str = start_time.utc.iso8601(6)

  #   values = valid_confirmed_bundle_uuids.map{ |bundle_uuid|
  #     {
  #       response_bundle_uuid: bundle_uuid,
  #       receiver_uuid:        receiver_uuid,
  #       created_at:           start_time_str,
  #       updated_at:           start_time_str,
  #     }
  #   }.sort_by{|value| value[:response_bundle_uuid]}

  #   target_response_bundle_uuids = values.map{|value| value[:response_bundle_uuid]}

  #   values_str = values.map{ |value|
  #     %Q{ ( '#{value[:response_bundle_uuid]}',
  #           '#{value[:receiver_uuid]}',
  #           TIMESTAMP WITH TIME ZONE '#{value[:created_at]}',
  #           TIMESTAMP WITH TIME ZONE '#{value[:updated_at]}' )
  #     }.gsub(/\n\s*/, ' ')
  #   }.join(',')

  #   ##
  #   ## Perform an UPSERT, ignoring conflicts.
  #   ##

  #   sql_newly_confirmed_bundle_uuids = %Q{
  #     INSERT INTO response_bundle_confirmations
  #       (response_bundle_uuid,receiver_uuid,created_at,updated_at)
  #     VALUES #{values_str}
  #     ON CONFLICT DO NOTHING
  #     RETURNING response_bundle_uuid
  #   }.gsub(/\n\s*/, ' ')

  #   newly_confirmed_bundle_uuids =
  #     ResponseBundleConfirmation.connection.execute(sql_newly_confirmed_bundle_uuids)
  #                               .collect{|hash| hash['response_bundle_uuid']}

  #   ##
  #   ## Collect now-confirmed ResponseBundle uuids.
  #   ##

  #   confirmed_bundle_uuids = ResponseBundleConfirmation.distinct
  #                                                      .where{response_bundle_uuid.in target_response_bundle_uuids}
  #                                                      .pluck(:response_bundle_uuid).to_a

  #   confirmed_bundle_uuids
  # end


  # def _get_bundles(max_bundles_to_return:,
  #                  receiver_uuid:,
  #                  partition_count:,
  #                  partition_modulo:)

  #   ##
  #   ## Find all bundle uuids that have not yet been confirmed
  #   ## by this receiver that also belong to the partition.
  #   ##

  #   sql_bundle_uuids = %Q{
  #     SELECT uuid FROM (
  #       SELECT * FROM response_bundles rb
  #       WHERE NOT EXISTS (
  #         SELECT response_bundle_uuid FROM response_bundle_confirmations rbc
  #         WHERE rbc.receiver_uuid = '#{receiver_uuid}'
  #         AND rb.uuid = rbc.response_bundle_uuid
  #       )
  #     ) AS unconfirmed
  #     WHERE unconfirmed.partition_value % #{partition_count} = #{partition_modulo}
  #     ORDER BY unconfirmed.is_open ASC, unconfirmed.created_at ASC
  #     LIMIT #{max_bundles_to_return}
  #   }.gsub(/\n\s*/, ' ')

  #   bundle_uuids =
  #     ResponseBundle.connection.execute(sql_bundle_uuids)
  #                   .map{|hash| hash.fetch('uuid')}

  #   ##
  #   ## Get the response data for the partition bundles.
  #   ##

  #   response_uuids = ResponseBundleEntry.where{response_bundle_uuid.in bundle_uuids}
  #                                       .map(&:response_uuid)

  #   response_data = Response.where{uuid.in response_uuids}
  #                           .map{ |response|
  #                             {
  #                               response_uuid:  response.uuid,
  #                               trial_uuid:     response.trial_uuid,
  #                               trial_sequence: response.trial_sequence,
  #                               learner_uuid:   response.learner_uuid,
  #                               question_uuid:  response.question_uuid,
  #                               is_correct:     response.is_correct,
  #                               responded_at:   response.responded_at,
  #                             }
  #                           }

  #   [ bundle_uuids, response_data ]
  # end


  # def _create_receipts(bundle_uuids:, receiver_uuid:)
  #   closed_bundle_uuids = ResponseBundle.where{uuid.in bundle_uuids}
  #                                       .where{is_open == false}
  #                                       .map(&:uuid)

  #   return if closed_bundle_uuids.none?

  #   ##
  #   ## Create the SQL value string.
  #   ##

  #   start_time     = Time.now
  #   start_time_str = start_time.utc.iso8601(6)

  #   values = closed_bundle_uuids.map{ |bundle_uuid|
  #     {
  #       response_bundle_uuid: bundle_uuid,
  #       receiver_uuid:        receiver_uuid,
  #       created_at:           start_time_str,
  #       updated_at:           start_time_str,
  #     }
  #   }.sort_by{|value| value[:response_bundle_uuid]}

  #   values_str = values.map{ |value|
  #     %Q{
  #       ( '#{value[:response_bundle_uuid]}',
  #         '#{value[:receiver_uuid]}',
  #         TIMESTAMP WITH TIME ZONE '#{value[:created_at]}',
  #         TIMESTAMP WITH TIME ZONE '#{value[:updated_at]}' )
  #     }.gsub(/\n\s*/, ' ')
  #   }.join(',')

  #   ##
  #   ## Perform an UPSERT, ignoring conflicts.
  #   ##

  #   sql_upsert_bundle_receipts = %Q{
  #     INSERT INTO response_bundle_receipts
  #       (response_bundle_uuid,receiver_uuid,created_at,updated_at)
  #     VALUES #{values_str}
  #     ON CONFLICT DO NOTHING
  #     RETURNING response_bundle_uuid
  #   }
  #   ResponseBundleReceipt.connection.execute(sql_upsert_bundle_receipts)
  #                        .collect{|hash| hash['response_bundle_uuid']}
  # end

# class BackgroundTasks::ResponseBundler
#   def initialize(bundle_response_limit:,
#                  bundle_age_limit:,
#                  process_response_limit:,
#                  partition_count:,
#                  partition_modulo:)
#     @bundle_response_limit  = bundle_response_limit
#     @bundle_age_limit       = bundle_age_limit
#     @process_response_limit = process_response_limit
#     @partition_count        = partition_count
#     @partition_modulo       = partition_modulo
#   end

#   def process
#     ResponseBundle.transaction(isolation: :serializable) do
#       ##
#       ## Collect the target unbundled Responses to be processed.
#       ##

#       sql_unbundled_responses = %Q{
#         SELECT * FROM (
#           SELECT * FROM responses
#           WHERE NOT EXISTS (
#             SELECT response_uuid FROM response_bundle_entries rbe
#             WHERE rbe.response_uuid = responses.uuid
#           )
#         ) AS target_response_uuids
#         WHERE target_response_uuids.partition_value % #{partition_count} = #{partition_modulo}
#         ORDER BY target_response_uuids.created_at ASC
#         LIMIT #{process_response_limit}
#       }.gsub(/\n\s*/, ' ')

#       unbundled_responses = Response.find_by_sql(sql_unbundled_responses)

#       ##
#       ## Add as many unbundled Responses as possible to existing
#       ## open target ResponseBundles.
#       ##

#       sql_open_response_bundles = %Q{
#         SELECT * FROM response_bundles
#         WHERE is_open IS TRUE
#         AND partition_value % #{partition_count} = #{partition_modulo}
#       }.gsub(/\n\s*/, ' ')

#       open_response_bundles = ResponseBundle.find_by_sql(sql_open_response_bundles)

#       open_response_bundles.each do |response_bundle|
#         num_bundle_responses = ResponseBundleEntry.where{response_bundle_uuid == response_bundle.uuid}
#                                                   .count

#         num_open_slots   = bundle_response_limit - num_bundle_responses
#         responses_to_add = unbundled_responses.shift(num_open_slots)

#         responses_to_add.each do |response|
#           ResponseBundleEntry.create!(
#             response_bundle_uuid: response_bundle.uuid,
#             response_uuid:        response.uuid,
#           )
#         end

#         if responses_to_add.count == num_open_slots
#           response_bundle.is_open = false
#           response_bundle.save!
#         end
#       end

#       ##
#       ## Add any remaining unbundled Responses to new ResponseBundles.
#       ##

#       unbundled_responses.each_slice(bundle_response_limit) do |responses|
#         is_open = (responses.count < bundle_response_limit)

#         response_bundle = ResponseBundle.create!(
#           uuid:            SecureRandom.uuid.to_s,
#           is_open:         is_open,
#           partition_value: rand(1000),
#         )

#         responses.each do |response|
#           ResponseBundleEntry.create!(
#             response_bundle_uuid: response_bundle.uuid,
#             response_uuid:        response.uuid,
#           )
#         end
#       end

#       ##
#       ## Close any "old" target ResponseBundles.
#       ##

#       old_response_bundles = ResponseBundle.find_by_sql(sql_open_response_bundles)
#                                            .select{|bundle| bundle.created_at <= Time.now - bundle_age_limit}
#                                            .to_a

#       old_response_bundles.each do |response_bundle|
#         response_bundle.is_open = false
#         response_bundle.save!
#       end
#     end
#   end

#   protected

#   attr_reader :bundle_response_limit
#   attr_reader :bundle_age_limit
#   attr_reader :process_response_limit
#   attr_reader :partition_count
#   attr_reader :partition_modulo
# end
