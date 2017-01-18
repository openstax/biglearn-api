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
  desc "Continuously create Response records"
  task :create, [:interval_sec,:num_responses] => :environment do |t, args|
    interval      = Float(args[:interval_sec]).seconds
    num_responses = Integer(args[:num_responses])

    service = Services::RecordResponses::Service.new

    at_most_every(interval) do
      response_data = num_responses.times.map{
        {
          response_uuid:  SecureRandom.uuid,
          trial_uuid:     SecureRandom.uuid,
          trial_sequence: Kernel::rand(10000),
          learner_uuid:   SecureRandom.uuid,
          question_uuid:  SecureRandom.uuid,
          is_correct:     [true, false].sample,
          responded_at:   Time.now.utc.iso8601(6),
        }
      }
      # puts "#{Time.now.utc.iso8601(6)}: creating:"
      # response_data.each{|data| puts "#{data.fetch(:response_uuid)} #{data.fetch(:responded_at)}"}
      service.process(response_data: response_data)
      puts "#{Time.now.utc.iso8601(6)}: created #{response_data.count} Responses"
    end
  end
end
