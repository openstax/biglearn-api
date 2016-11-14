def at_most_every(duration, &block)
  loop do
    t1 = Time.now
    block.call
    t2 = Time.now
    elapsed = t2 - t1
    sleep(duration - elapsed) if duration > elapsed
  end
end

namespace :event do
  desc "continuously create serialized events (max_events_per_sec, isolation_level)"
  task :loop, [:max_events_per_sec,:isolation_level] => :environment do |t, args|
    max_events_per_sec  = Float(args[:max_events_per_sec]).seconds
    isolation_level     = args[:isolation_level].to_sym

    course_uuids = CourseSequenceNumber.find_each.map(&:course_uuid)

    max_retries = 0

    next_summary_time = Time.now + 1.0.seconds
    last_summary_time = Time.now
    last_num_events   = 0
    num_events        = 0

    at_most_every(1.0/max_events_per_sec) do
      course_uuid = course_uuids.sample

      num_retries = 0
      begin
        CourseEvent.transaction(isolation: isolation_level) do
          course_sequence_number = CourseSequenceNumber.lock.find_by(course_uuid: course_uuid)
          course_sequence_number.sequence_number += 1
          course_sequence_number.save!

          if Kernel.rand > 0.5
            event = ExperOneEvent.create!(
              uuid: SecureRandom.uuid.to_s,
              data: Kernel.rand(100),
            )
          else
            event = ExperTwoEvent.create!(
              uuid: SecureRandom.uuid.to_s,
              data: Kernel.rand(100),
            )
          end

          course_event = CourseEvent.create!(
            uuid:            SecureRandom.uuid.to_s,
            course_uuid:     course_uuid,
            sequence_number: course_sequence_number.sequence_number,
            event:           event,
          )
        end
      rescue ActiveRecord::StatementInvalid => err
        num_retries += 1
        max_retries = num_retries if num_retries > max_retries
        # puts "num_retries = #{num_retries} (max=#{max_retries})"
        retry
      end

      num_events += 1

      current_time = Time.now
      if current_time > next_summary_time
        events_per_sec = (num_events - last_num_events) / (next_summary_time - last_summary_time)
        puts "#{current_time.iso8601(6)}: events_per_sec=%03.3f  max_retries=%03d" % [events_per_sec, max_retries]

        max_retries       = 0
        last_num_events   = num_events
        last_summary_time = current_time
        next_summary_time = current_time + 1.0.seconds
      end
    end
  end
end
