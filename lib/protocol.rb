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
      my_record, group_records = _read_records
      unless my_record
        _create_record
        next
      end

      am_boss, boss_record = _get_boss_situation(group_records)

      my_record.boss_uuid = boss_record ? boss_record.instance_uuid : my_record.instance_uuid
      _save_record(my_record)

      if !boss_record
        puts 'election!'
        _elect_new_boss
        next
      end

      if am_boss
        my_record.boss_instance_count = group_records.count
        _save_record(my_record)

        dead_records = _read_dead_records
        dead_records.map(&:destroy!)

        actual_modulos = group_records.map(&:instance_modulo).sort
        target_modulos = (0..group_records.count-1).to_a
        if actual_modulos != target_modulos
          my_record.boss_command = 'allocate_modulos'
          _save_record(my_record)
        else
          my_record.boss_command = 'work'
          _save_record(my_record)
        end
      end


      am_boss, boss_record = _get_boss_situation(group_records)
      next unless boss_record

      case boss_record.boss_command
      # when 'clear_modulos'
      #   puts 'clear_modulos!'
      #   _clear_modulos
      when 'allocate_modulos'
        puts 'allocate_modulos!'
        _allocate_modulos
      when 'work'
        curent_time = Time.now
        if my_record.instance_modulo < 0
          sleep(0.5)
        elsif curent_time - last_work_time >= @min_work_interval
          last_work_time = curent_time
          # puts "#{my_record.instance_uuid} #{my_record.instance_modulo} #{am_boss} #{boss_record.instance_uuid} - WORK"
          # sleep(0.1)
          @work_block.call(
            instance_count:  boss_record.boss_instance_count,
            instance_modulo: my_record.instance_modulo,
          )
        else
          sleep([0.5, (last_work_time + @min_work_interval - curent_time)].min)
        end
      else
        puts "#{my_record.instance_uuid} #{my_record.instance_modulo} #{am_boss} #{boss_record.instance_uuid} ..."
        sleep(1)
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
    loop do
      retries ||= 0

      begin
        modulo = -1000 - rand(1_000)

        ActiveRecord::Base.connection_pool.with_connection do
          ProtocolRecord.create!(
            protocol_name:       @protocol_name,
            group_uuid:          @group_uuid,
            instance_uuid:       @instance_uuid,
            boss_uuid:           SecureRandom.uuid.to_s,
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
    group_records = ActiveRecord::Base.connection_pool.with_connection do
      ProtocolRecord.where{group_uuid == my{@group_uuid}}
                    .where{updated_at > Time.now - 10.seconds}.to_a
    end
    my_record = group_records.detect{|rec| rec.instance_uuid == @instance_uuid}
    [my_record, group_records]
  end

  def _read_dead_records
    dead_records = ActiveRecord::Base.connection_pool.with_connection do
      ProtocolRecord.where{group_uuid == my{@group_uuid}}
                    .where{updated_at <= Time.now - 10.seconds}.to_a
    end
    dead_records
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


  def _elect_new_boss
    my_record, group_records = _read_records

    am_boss, boss_record = _get_boss_situation(group_records)
    return if boss_record

    lowest_uuid = group_records.map(&:instance_uuid).sort.first

    my_record.boss_uuid        = lowest_uuid
    my_record.boss_command     = 'none'
    my_record.instance_command = 'elect'

    _save_record(my_record)

    loop do
      start_time ||= Time.now

      my_record, group_records = _read_records
      am_boss, boss_record = _get_boss_situation(group_records)

      break if boss_record
      raise 'election failed' if start_time < Time.now - 10.seconds

      sleep(0.1)
    end
  end

  def _allocate_modulos
    loop do
      start_time ||= Time.now

      my_record, group_records = _read_records
      am_boss, boss_record = _get_boss_situation(group_records)
      return if !boss_record

      begin
        my_record.instance_command = 'allocate_modulos'
        my_record.instance_modulo  = -1000 - rand(1000)

        _save_record(my_record)
      rescue ActiveRecord::WrappedDatabaseException
        sleep(0.1)
        next
      end

      my_record, group_records = _read_records
      am_boss, boss_record = _get_boss_situation(group_records)
      return if !boss_record

      boss_instance_count = boss_record.boss_instance_count

      success = false
      boss_instance_count.times do |target_modulo|
        puts "target_modulo = #{target_modulo}"
        begin
          my_record, group_records = _read_records

          my_record.instance_command = 'allocate_modulos'
          my_record.instance_modulo  = target_modulo

          _save_record(my_record)
          success = true
        rescue ActiveRecord::WrappedDatabaseException
          sleep(0.1)
          next
        end
      end

      break if success
      raise "could not allocate modulos" if start_time < Time.now - 10.seconds
      sleep(0.1)
    end

    _wait_for_boss
  end

  def _wait_for_boss
    loop do
      my_record, group_records = _read_records
      am_boss, boss_record = _get_boss_situation(group_records)
      return if !boss_record

      my_record.instance_command = 'wait_for_boss'
      _save_record(my_record)

      if am_boss
        if group_records.all?{|rec| rec.instance_command == 'wait_for_boss'}
          my_record.boss_command     = 'none'
          my_record.instance_command = 'none'
          _save_record(my_record)
          break
        end
      else
        if boss_record.boss_command == 'none'
          my_record.instance_command = 'none'
          _save_record(my_record)
          break
        end
      end

      sleep(0.1)
    end

    loop do
      my_record, group_records = _read_records
      am_boss, boss_record = _get_boss_situation(group_records)
      return if !boss_record || !am_boss

      break if group_records.all?{|rec| rec.instance_command == 'none'}
      sleep(0.1)
    end
  end

  def self.at_most_every(duration, &block)
    loop do
      t1 = Time.now
      block.call(instance_count: 2, instance_modulo: 1)
      t2 = Time.now
      elapsed = t2 - t1
      sleep(duration - elapsed) if duration > elapsed
    end
  end
end
