namespace :protocol do
  desc "Join the 'exper' protocol group"
  task :exper, [:group_uuid] => :environment do |t, args|
    group_uuid = args[:group_uuid]

    protocol = ExperProtocol.new(group_uuid: group_uuid) do |instance_count:, instance_modulo:|
      puts "#{group_uuid}[#{instance_modulo}/#{instance_count}] working away as usual..."
    end

    protocol.run
  end
end
