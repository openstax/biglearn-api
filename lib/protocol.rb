class Protocol

  def initialize(protocol_name:,
                 min_work_interval:,
                 work_modulo: 1.0.seconds,
                 work_offset: 0.0.seconds,
                 group_uuid:,
                 &block)
    @protocol_name      = protocol_name
    @min_work_interval  = min_work_interval
    @work_modulo        = work_modulo
    @work_offset        = work_offset
    @group_uuid         = group_uuid
    @work_block         = block
    @instance_uuid      = SecureRandom.uuid.to_s
  end

  def compute_first_work_time(time:)
    mod1 = time.to_f % @work_modulo
    time - mod1 + @work_offset + @min_work_interval
  end

  def compute_next_work_time(last_time:, current_time:)
    next_time = last_time + @min_work_interval
  end

  def run
    ActiveRecord::Base.clear_active_connections!

    current_time = Time.now
    next_work_time = compute_first_work_time(time: current_time)
    # puts "current_time:   #{round_time(time: current_time).utc.iso8601(6)}"
    # puts "next_work_time: #{round_time(time: next_work_time).utc.iso8601(6)}"

    loop do
      my_record, group_records, dead_records = _read_records
      unless my_record
        puts "create!"
        _create_record
        next
      end

      am_boss, boss_record = _get_boss_situation(group_records)
      unless boss_record
        puts "elect!"
        _elect_new_boss(my_record, group_records)
        next
      end

      my_record.boss_uuid      = boss_record.instance_uuid
      my_record.instance_count = group_records.count
      _save_record(my_record)

      if am_boss && dead_records.any?
        puts "destroy!"
        dead_records.map(&:destroy)
        next
      end

      actual_modulos = group_records.map(&:instance_modulo).sort
      target_modulos = (0..boss_record.instance_count-1).to_a
      if actual_modulos != target_modulos
        puts "allocate needed!"
        if (my_record.instance_modulo < 0) || (my_record.instance_modulo >= boss_record.instance_count)
          puts "allocate myself!"
          _allocate_modulo(my_record, group_records)
        end
        sleep(0.1)
        next
      end

      if (my_record.instance_modulo < 0) || (my_record.instance_modulo >= boss_record.instance_count)
        raise "instance_modulo error (#{my_record.instance_modulo} / #{boss_record.instance_count})"
      end

      current_time = Time.now
      # puts "current_time:   #{round_time(time: current_time).utc.iso8601(6)}"
      if current_time >= next_work_time
        last_work_time = next_work_time
        # puts "work_time:      #{round_time(time: last_work_time).utc.iso8601(6)}"
        # puts "(am boss)" if am_boss
        @work_block.call(
          instance_count:  boss_record.instance_count,
          instance_modulo: my_record.instance_modulo,
        )
        current_time = Time.now
        # next_work_time = last_work_time + ((current_time - last_work_time + @min_work_interval - 0.000001.seconds)/@min_work_interval).to_i*@min_work_interval
        next_work_time = compute_next_work_time(last_time: next_work_time, current_time: current_time)
        # puts "next_work_time: #{round_time(time: next_work_time).utc.iso8601(6)}"
      else
        sleep_interval = [0.5, next_work_time - current_time].min
        # puts "sleeping for #{sleep_interval}"
        sleep(sleep_interval)
      end
    end
  rescue Interrupt => ex
    puts 'exiting'
  rescue Exception => ex
    raise ex
  ensure
    _destroy_record
  end


  def _create_record
    puts "create!"

    loop do
      retries ||= 0

      begin
        modulo = -1000 - rand(1_000)

        ActiveRecord::Base.connection_pool.with_connection do
          ProtocolRecord.create!(
            protocol_name:       @protocol_name,
            group_uuid:          @group_uuid,
            instance_uuid:       @instance_uuid,
            instance_count:      1,
            instance_modulo:     modulo,
            boss_uuid:           @instance_uuid,
          )
        end

        break
      rescue ActiveRecord::WrappedDatabaseException
        retry if (retries += 1) < 20
        raise "failed after #{retries} retries"
      end
    end
  end


  def _save_record(record)
    ActiveRecord::Base.connection_pool.with_connection do
      record.touch
      record.save!
    end
  end


  def _destroy_record
    my_record = ActiveRecord::Base.connection_pool.with_connection do
      ProtocolRecord.where{instance_uuid == my{@instance_uuid}}.first
    end
    my_record.destroy! if my_record
  end


  def _read_records
    all_records = ActiveRecord::Base.connection_pool.with_connection do
      ProtocolRecord.where{group_uuid == my{@group_uuid}}.to_a
    end

    group_records = all_records.select{|rec| rec.updated_at > Time.now - 10.seconds}
    dead_records  = all_records - group_records
    my_record     = all_records.detect{|rec| rec.instance_uuid == @instance_uuid}

    [my_record, group_records, dead_records]
  end


  def _get_boss_situation(group_records)
    uuid, votes = group_records.group_by(&:boss_uuid)
                               .inject({}){|result, (uuid, group)|
                                  result[uuid] = group.size
                                  result
                               }.sort_by{|uuid, size| size}
                               .last

    boss_uuid = (votes > group_records.count/2.0) ? uuid : nil
    boss_uuid = nil unless group_records.detect{|rec| rec.instance_uuid == boss_uuid}

    boss_record = group_records.detect{|rec| rec.instance_uuid == boss_uuid}
    am_boss = (boss_uuid == @instance_uuid)

    [am_boss, boss_record]
  end


  def _elect_new_boss(my_record, group_records)
    lowest_uuid = group_records.map(&:instance_uuid).sort.first

    my_record.boss_uuid      = lowest_uuid
    my_record.instance_count = group_records.count

    _save_record(my_record)
    sleep(0.1)
  end


  def _allocate_modulo(my_record, group_records)
    am_boss, boss_record = _get_boss_situation(group_records)
    return if !boss_record

    boss_instance_count = boss_record.instance_count

    all_modulos = (0..boss_instance_count-1).to_a
    taken_modulos = group_records.select{ |rec|
      (rec.instance_modulo >= 0) && (rec.instance_modulo < boss_instance_count)
    }.map(&:instance_modulo).sort

    available_modulos = all_modulos - taken_modulos

    available_modulos.each do |target_modulo|
      begin
        my_record.instance_modulo = target_modulo
        my_record.instance_count  = group_records.count
        _save_record(my_record)
        break
      rescue ActiveRecord::WrappedDatabaseException
        sleep(0.1)
      end
    end

    sleep(0.1)
  end

end
