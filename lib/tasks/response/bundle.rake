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
  desc "Continuously bundle Responses (interval, max to process, max age, max per, count, modulo)"
  task :bundle, [:interval_sec,:max_to_process,:max_age_sec,:max_per,:count,:modulo] => :environment do |t, args|
    interval       = Float(args[:interval_sec]).seconds
    max_to_process = Integer(args[:max_to_process])
    max_age        = Float(args[:max_age_sec]).seconds
    max_per        = Integer(args[:max_per])
    count          = Integer(args[:count])
    modulo         = Integer(args[:modulo])

    service = Services::BundleResponses::Service.new

    at_most_every(interval) do
      service.process(
        max_responses_to_process: max_to_process,
        max_responses_per_bundle: max_per,
        max_age_per_bundle:       max_age,
        partition_count:          count,
        partition_modulo:         modulo,
      )
      puts "#{Time.now.utc.iso8601(6)} (#{modulo}/#{count}): bundled Responses"
    end
  end
end
