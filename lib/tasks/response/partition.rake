def at_most_every(duration, &block)
  loop do
    t1 = Time.now
    block.call
    t2 = Time.now
    elapsed = t2 - t1
    sleep(duration - elapsed) if duration > elapsed
  end
end

namespace :response do
  desc "Continuously partition Responses"
  task :partition, [:interval_sec,:max_responses_to_process] => :environment do |t, args|
    interval                 = Float(args[:interval_sec]).seconds
    max_responses_to_process = Integer(args[:max_responses_to_process])

    service = Services::PartitionResponses::Service.new

    at_most_every(interval) do
      service.process(max_responses_to_process: max_responses_to_process)
      puts "#{Time.now.utc.iso8601(6)}: partitioned Responses"
    end
  end
end
