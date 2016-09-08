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
  desc "Continuously fetch/confirm Responses"
  task :fetch, [:interval_sec,:receiver_uuid,:count,:modulo] => :environment do |t, args|
    interval       = Float(args[:interval_sec]).seconds
    receiver_uuid  = args[:receiver_uuid]
    count          = Integer(args[:count])
    modulo         = Integer(args[:modulo])

    service = Services::FetchResponseBundles::Service.new

    unconfirmed_bundle_uuids = {}
    seen_response_uuids      = {}
    delays                   = {}

    next_delay_update_time = Time.now + (1.0).seconds

    at_most_every(interval) do
      bundle_uuids_to_confirm = unconfirmed_bundle_uuids.keys.take(500)

      results = service.process(
        goal_max_responses_to_return: 1000,
        max_bundles_to_process:       100,
        bundle_uuids_to_confirm:      bundle_uuids_to_confirm,
        receiver_uuid:                receiver_uuid,
        partition_count:              count,
        partition_modulo:             modulo,
      )

      results.fetch(:confirmed_bundle_uuids).each do |uuid|
        unconfirmed_bundle_uuids.delete(uuid)
      end

      results.fetch(:bundle_uuids).each do |uuid|
        unconfirmed_bundle_uuids[uuid] = true
      end

      new_response_uuids = []
      results.fetch(:response_data).each do |data|
        unless seen_response_uuids[data.fetch(:response_uuid)]
          new_response_uuids << data.fetch(:response_uuid)
          delays[data.fetch(:response_uuid)] = Time.now - Time.parse(data.fetch(:responded_at))
        end
        seen_response_uuids[data.fetch(:response_uuid)] = true
      end

      puts "#{Time.now.utc.iso8601(6)} #{receiver_uuid} (#{modulo}/#{count}): fetched Responses (received: #{results.fetch(:response_data).count}, new: #{new_response_uuids.count}, confirmed: #{results.fetch(:confirmed_bundle_uuids).count})"

      if Time.now > next_delay_update_time
        next_delay_update_time = Time.now + (2.0).seconds

        avg_delay = delays.none? ? 0.0 : delays.values.inject(&:+) / delays.values.count
        max_delay = delays.values.max || 0.0
        min_delay = delays.values.min || 0.0

        puts "delays: #{min_delay}, #{avg_delay}, #{max_delay}"
        # delays = {}
      end
    end
  end
end
