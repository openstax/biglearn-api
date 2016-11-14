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
  desc "continuously check event updates for consistency"
  task :check, [:max_checks_per_sec] => :environment do |t, args|
    max_checks_per_sec = Float(args[:max_checks_per_sec])

    at_most_every(1.0/max_checks_per_sec) do
      CourseSequenceNumber.transaction(isolation: :repeatable_read) do
        results = {}

        CourseSequenceNumber.find_each do |course_sequence_number|
          results[course_sequence_number.course_uuid] = {
            course_uuid:     course_sequence_number.course_uuid,
            sequence_number: course_sequence_number.sequence_number,
            num_event_ones:  0,
            num_event_twos:  0,
          }
        end

        results.each do |uuid, values|
          values[:num_event_ones] = CourseEvent.where{course_uuid == uuid}
                                               .where{event_type == "ExperOneEvent"}
                                               .count
          values[:num_event_twos] = CourseEvent.where{course_uuid == uuid}
                                               .where{event_type == "ExperTwoEvent"}
                                               .count
        end

        puts "#{Time.now.iso8601(6)}:"
        results.each do |course_uuid,values|
          sn       = values[:sequence_number]
          num_ones = values[:num_event_ones]
          num_twos = values[:num_event_twos]
          pass     = sn == num_ones + num_twos

          puts "  #{course_uuid} sn=%05.5d 1s=%05.5d 2s=%05.5d pass=#{pass}" % [sn, num_ones, num_twos]
        end
      end
    end
  end
end
