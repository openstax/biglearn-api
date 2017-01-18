class Openstax::BundleManager::Manager

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

    t1 = Time.now

    sql_target_records = %Q{
      SELECT mt.* FROM #{model_table} mt
      LEFT OUTER JOIN #{bundle_model_table} bmt
      ON mt.uuid = bmt.uuid
      WHERE bmt.uuid IS NULL
      AND   mt.created_at > '#{(Time.now - 10.seconds).utc.iso8601(6)}'::timestamptz
      ORDER BY mt.created_at ASC
      LIMIT #{max_records_to_process}
    }.gsub(/\n\s*/, ' ')

    # puts sql_target_records

    target_records = model.find_by_sql(sql_target_records)

    t2 = Time.now

    ##
    ## Upsert a Bundle::Model record for each target Model record.
    ##

    bundle_models = target_records.map{ |record|
      bundle_model.new(
        uuid:            record.uuid,
        partition_value: Kernel::rand(10000),
      )
    }.sort_by{|bundle_model| bundle_model.uuid}

    t3 = Time.now

    bundle_model.import bundle_models, on_duplicate_key_ignore: true

    t4 = Time.now

    # puts "times = #{[t2,t3,t4].map{|t| t-t1}}"
    self
  end


  def bundle(max_records_to_process:,
             max_records_per_bundle:,
             max_age_per_bundle:,
             partition_count:,
             partition_modulo:)

    if true
      sql_bundle_records_to_process = %Q{
        SELECT bmt.* FROM #{bundle_model_table} bmt
        LEFT OUTER JOIN #{bundle_entry_model_table} bemt
        ON bemt.uuid = bmt.uuid
        WHERE bemt.uuid IS NULL
        AND bmt.created_at > '#{(Time.now.utc-10.seconds).iso8601(6)}'::timestamptz
        AND bmt.partition_value % #{partition_count} = #{partition_modulo}
        ORDER BY bmt.created_at ASC
        LIMIT #{max_records_to_process}
      }.gsub(/\n\s*/, ' ')

      bundle_records = bundle_model.find_by_sql(sql_bundle_records_to_process)

      bundle_infos = bundle_records.each_slice(max_records_per_bundle).inject([]) do |result, records|
        if (records.count == max_records_per_bundle) || (Time.now - records.first.created_at >= max_age_per_bundle)
          bundle_bundle = bundle_bundle_model.new(
            uuid:            SecureRandom.uuid,
            partition_value: Kernel::rand(10000),
          )

          bundle_entries = records.map{ |record|
            bundle_entry_model.new(
              uuid:        record.uuid,
              bundle_uuid: bundle_bundle.uuid,
            )
          }

          result << [bundle_bundle, bundle_entries]
        end
        result
      end

      bundle_bundles = bundle_infos.map{|bundle_info| bundle_info.fetch(0)}
      bundle_entries = bundle_infos.map{|bundle_info| bundle_info.fetch(1)}.flatten

      if bundle_bundles.any?
        bundle_bundle_model.import bundle_bundles
        bundle_entry_model.import  bundle_entries
      end
    else
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
          uuid:             SecureRandom.uuid,
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
    self
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
      SELECT uuid FROM #{bundle_bundle_model_table} bbmt
      LEFT OUTER JOIN #{bundle_confirmation_model_table} bcmt
      ON    bcmt.receiver_uuid = '#{receiver_uuid}'
      AND   bcmt.bundle_uuid = bbmt.uuid
      WHERE bcmt.bundle_uuid IS NULL
      AND   bbmt.uuid IN (#{bundle_uuid_str})
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
      SELECT uuid FROM #{bundle_bundle_model_table} bbmt
      LEFT OUTER JOIN #{bundle_confirmation_model_table} bcmt
      ON bcmt.bundle_uuid = bbmt.uuid
      AND bcmt.receiver_uuid = '#{receiver_uuid}'
      WHERE bcmt.bundle_uuid IS NULL
      AND bbmt.created_at > '#{(Time.now.utc-10.seconds).iso8601(6)}'::timestamptz
      AND bbmt.partition_value % #{partition_count} = #{partition_modulo}
      ORDER BY bbmt.created_at ASC
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
        SELECT bmt.uuid FROM #{bundle_model_table} bmt
        LEFT OUTER JOIN #{bundle_entry_model_table} bemt
        ON bemt.uuid = bmt.uuid
        WHERE bemt.uuid IS NULL
        AND bmt.created_at > '#{(Time.now.utc-10.seconds).iso8601(6)}'::timestamptz
        AND bmt.partition_value % #{partition_count} = #{partition_modulo}
        ORDER BY bmt.created_at ASC
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
