class Protocol

  def initialize(protocol_name:, min_work_interval:, group_uuid:, &block)
    @protocol_name      = protocol_name
    @min_work_interval  = min_work_interval
    @group_uuid         = group_uuid
    @work_block         = block
    @instance_uuid      = SecureRandom.uuid.to_s
  end


  def run
    ActiveRecord::Base.clear_active_connections!

    last_work_time = Time.now - 1.year

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

      my_record.boss_uuid = boss_record.instance_uuid
      if am_boss
        my_record.boss_instance_count = group_records.count
      else
        my_record.boss_instance_count = -1
      end
      _save_record(my_record)

      if am_boss && dead_records.any?
        puts "destroy!"
        dead_records.map(&:destroy)
        next
      end

      actual_modulos = group_records.map(&:instance_modulo).sort
      target_modulos = (0..boss_record.boss_instance_count-1).to_a
      if actual_modulos != target_modulos
        puts "allocate needed!"
        if (my_record.instance_modulo < 0) || (my_record.instance_modulo >= boss_record.boss_instance_count)
          puts "allocate myself!"
          _allocate_modulo(my_record, group_records)
        end
        sleep(0.1)
        next
      end

      if (my_record.instance_modulo < 0) || (my_record.instance_modulo >= boss_record.boss_instance_count)
        raise "instance_modulo error (#{my_record.instance_modulo} / #{boss_record.boss_instance_count})"
      end

      # puts "work!"
      curent_time = Time.now
      if curent_time - last_work_time >= @min_work_interval
        last_work_time = curent_time
        @work_block.call(
          instance_count:  boss_record.boss_instance_count,
          instance_modulo: my_record.instance_modulo,
        )
      else
        sleep([0.5, (last_work_time + @min_work_interval - curent_time)].min)
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
            boss_uuid:           @instance_uuid,
            boss_command:        'none',
            boss_instance_count:  -1,
            instance_command:    'none',
            instance_status:     'none',
            instance_modulo:     modulo,
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

    # puts "uuid: #{uuid} votes: #{votes} count: #{group_records.count}"

    boss_uuid = (votes > group_records.count/2.0) ? uuid : nil
    boss_uuid = nil unless group_records.detect{|rec| rec.instance_uuid == boss_uuid}

    boss_record = group_records.detect{|rec| rec.instance_uuid == boss_uuid}
    am_boss = (boss_uuid == @instance_uuid)

    [am_boss, boss_record]
  end


  def _elect_new_boss(my_record, group_records)
    lowest_uuid = group_records.map(&:instance_uuid).sort.first

    my_record.boss_uuid           = lowest_uuid
    my_record.boss_command        = 'none'
    my_record.boss_instance_count = group_records.count
    my_record.instance_command    = 'elect'

    _save_record(my_record)
    sleep(0.1)
  end


  def _allocate_modulo(my_record, group_records)
    am_boss, boss_record = _get_boss_situation(group_records)
    return if !boss_record

    boss_instance_count = boss_record.boss_instance_count

    all_modulos = (0..boss_instance_count-1).to_a
    taken_modulos = group_records.select{ |rec|
      (rec.instance_modulo >= 0) && (rec.instance_modulo < boss_instance_count)
    }.map(&:instance_modulo).sort

    available_modulos = all_modulos - taken_modulos

    puts "boss_instance_count = #{boss_instance_count}"
    puts "all_modulos:       #{all_modulos}"
    puts "taken_modulos:     #{taken_modulos}"
    puts "available_modulos: #{available_modulos}"

    available_modulos.each do |target_modulo|
      puts "target_modulo = #{target_modulo}"
      begin
        my_record.instance_command = 'allocate_modulos'
        my_record.instance_modulo  = target_modulo

        _save_record(my_record)
        break
      rescue ActiveRecord::WrappedDatabaseException
        sleep(0.1)
      end
    end

    sleep(0.1)
  end

end
