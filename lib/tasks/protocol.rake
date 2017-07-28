class Worker
  def initialize(group_uuid:)
    @group_uuid = group_uuid
    @counter    = 0
  end

  def do_work(count:, modulo:)
    @counter += 1
    puts "#{Time.now.utc.iso8601(6)} #{@group_uuid}:[#{modulo}/#{count}] #{@counter % 10} working away as usual..."
    sleep(0.1)
  end
end

namespace :protocol do
  desc "Join the 'exper' protocol group"
  task :exper, [:group_uuid, :work_interval, :work_modulo, :work_offset] => :environment do |t, args|
    group_uuid    = args[:group_uuid]
    work_interval = (args[:work_interval] || '1.0').to_f.seconds
    work_modulo   = (args[:work_modulo]   || '1.0').to_f.seconds
    work_offset   = (args[:work_offset]   || '0.0').to_f.seconds

    worker = Worker.new(group_uuid: group_uuid)

    protocol = Protocol.new(
      protocol_name: 'exper',
      min_work_interval: work_interval,
      work_modulo: work_modulo,
      work_offset: work_offset,
      group_uuid: group_uuid
    ) do |instance_count:, instance_modulo:|
      worker.do_work(count: instance_count, modulo: instance_modulo)
    end

    protocol.run
  end
end
