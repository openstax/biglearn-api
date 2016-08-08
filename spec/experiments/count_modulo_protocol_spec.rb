require 'rails_helper'

class Protocol
  PROTOCOL_NAME = 'protocol_name_here'

  attr_reader   :receiver_uuid
  attr_reader   :instance_uuid
  attr_accessor :modulo

  def initialize(receiver_uuid:)
    @receiver_uuid = receiver_uuid
    @instance_uuid = SecureRandom.uuid.to_s
    @modulo        = -1

    loop do
      retries ||= 0

      begin
        @modulo = -1000 - rand(1_000)

        ActiveRecord::Base.connection_pool.with_connection do
          ProtocolRecord.create!(
            protocol_name:       PROTOCOL_NAME,
            receiver_uuid:       @receiver_uuid,
            instance_uuid:       @instance_uuid,
            boss_uuid:           @instance_uuid,
            boss_command:        'none',
            boss_instance_count:  -1,
            instance_command:    'none',
            instance_status:     'none',
            instance_modulo:     @modulo,
          )
        end

        break
      rescue ActiveRecord::WrappedDatabaseException
        retry if (retries += 1) < 20
        raise "failed after #{retries} retries"
      end
    end
  end

  def _get_records
    records = ActiveRecord::Base.connection_pool.with_connection do
      ProtocolRecord.where{receiver_uuid == my{@receiver_uuid}}.to_a
    end
    records
  end

  def _get_instance_record
    instance_record = ActiveRecord::Base.connection_pool.with_connection do
      ProtocolRecord.where{instance_uuid == my{@instance_uuid}}.to_a.first
    end
    instance_record
  end

  def _alive_boss_uuid(records:)
    uuid, votes = records.select{|record| record.updated_at > Time.now - 10.seconds}
                         .group_by(&:boss_uuid)
                         .inject({}){|result, (uuid, group)|
                            result[uuid] = group.size
                            result
                         }.sort_by{|uuid, size| size}
                         .last

    boss_uuid = (votes > records.count/2.0) ? uuid : nil
    boss_uuid
  end

  def _alive_boss_exists?(records:)
    !!_alive_boss_uuid(records: records)
  end

  def _elect_new_boss
    records =
      loop do
        records = _get_records
        break records if _alive_boss_exists?(records: records)

        lowest_uuid = records.map(&:instance_uuid).sort.first

        instance_record = _get_instance_record

        instance_record.boss_uuid        = lowest_uuid
        instance_record.boss_command     = 'none'
        instance_record.instance_command = 'elect'
        instance_record.instance_status  = 'in_progress'

        ActiveRecord::Base.connection_pool.with_connection do
          instance_record.save!
        end
      end

    boss_uuid = _alive_boss_uuid(records: records)

    instance_record = _get_instance_record

    instance_record.boss_uuid        = boss_uuid
    instance_record.instance_command = 'elect'
    instance_record.instance_status  = 'done'

    if boss_uuid == instance_record.instance_uuid
      instance_record.boss_instance_count = records.count
    else
      instance_record.boss_instance_count = -1
    end

    ActiveRecord::Base.connection_pool.with_connection do
      instance_record.save!
    end

    self
  end

  def negotiate

    # if _alive_boss_exists(records)
    #   @receiver_protocol_record.boss_uuid = _boss_uuid(records)
    #   if _am_boss(records)
    #     @receiver_protocol_record.boss_command        = 'wait'
    #     @receiver_protocol_record.boss_instance_count = records.count
    #   else
    #     @receiver_protocol_record.boss_command        = 'none'
    #     @receiver_protocol_record.boss_instance_count = -1
    #     @receiver_protocol_record.instance_command    = 'negotiate'
    #   case _get_boss_command(records)
    #   when 'wait'
    #     sleep(0.1)
    #   when 'negotiate'
    #   end
    # else
    #   _elect_new_boss
    # end
    # ActiveRecord::Base.connection_pool.with_connection do
    #   self.receiver_protocol_record.receiver_state = 'request_negotiation'
    #   self.receiver_protocol_record.save!
    # end

    # # puts "request negotiation sleeping"
    # # sleep(2)

    # ##
    # ## wait for all live processes to reach request_negotiation state
    # ##

    # loop do
    #   start_time ||= Time.now

    #   receivers_to_wait_on = ActiveRecord::Base.connection_pool.with_connection do
    #     self.receiver_protocol_record.touch

    #     ProtocolRecord.where{receiver_uuid == my{receiver_uuid}}
    #                     .where{receiver_state != 'request_negotiation'}
    #                     .where{updated_at > Time.now - 10.seconds}
    #   end

    #   break if receivers_to_wait_on.none?
    #   raise "could not negotiate" if Time.now > start_time + 10.seconds
    #   sleep(0.25)
    # end

    # puts "ready to regotiate sleeping"
    # sleep(2)

    ##
    ##
    ##

    self
  end
end

RSpec.describe 'count-modulo protocol' do
  context 'multiple threads' do
    it 'negotiates modulo value correctly' do
      expect(ProtocolRecord.count).to eq(0)
      ActiveRecord::Base.clear_active_connections!

      num_threads = 10
      receiver_uuid = SecureRandom.uuid.to_s

      modulos = Array.new(num_threads) { -1 }

      wait_for_it = true
      threads = num_threads.times.map do |thread_idx|
        Thread.new do
          loop do
            break unless wait_for_it
          end

          proto = Protocol.new(receiver_uuid: receiver_uuid)
          records = proto._get_records
          proto._elect_new_boss
          modulos[thread_idx] = proto._get_instance_record.boss_uuid == proto.instance_uuid
        end
      end

      wait_for_it = false

      threads.map(&:join)

      ProtocolRecord.find_each{|rec| puts rec.inspect}
      puts "modulos: #{modulos}"
    end
  end
end
