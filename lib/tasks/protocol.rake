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
  task :exper, [:group_uuid] => :environment do |t, args|
    group_uuid = args[:group_uuid]

    worker = Worker.new(group_uuid: group_uuid)

    protocol = Protocol.new(
      protocol_name: 'exper',
      min_work_interval: 2.0.seconds,
      work_offset: 2.seconds,
      group_uuid: group_uuid
    ) do |instance_count:, instance_modulo:|
      worker.do_work(count: instance_count, modulo: instance_modulo)
    end

    protocol.run
  end
end
