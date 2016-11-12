require 'rails_helper'

RSpec.describe "event experiments" do
  it "it works" do
    num_threads = 6
    num_courses = 1
    num_loops   = 100

    course_uuids = num_courses.times.map{ SecureRandom.uuid.to_s }

    course_uuids.each do |course_uuid|
      begin
        CourseSequenceNumber.transaction(isolation: :repeatable_read) do
          CourseSequenceNumber.find_or_create_by(course_uuid: course_uuid) { |course_sequence_number|
            course_sequence_number.sequence_number = 0
          }
        end
      rescue ActiveRecord::RecordNotUnique
        puts "here"
      end
    end

    ActiveRecord::Base.clear_active_connections!

    num_retries = 0
    wait_for_it = true

    threads = num_threads.times.map do |thread_num|
      Thread.new do
        while wait_for_it
        end

        num_loops.times do |loop_num|
          puts "begin #{thread_num} #{loop_num}"
          ActiveRecord::Base.connection_pool.with_connection do
            begin
              # CourseEvent.transaction(isolation: :serializable) do
              CourseEvent.transaction(isolation: :read_committed) do
                sleep(0.05)
                event = ExperOneEvent.new(
                  uuid: SecureRandom.uuid.to_s,
                  data: Kernel.rand(100),
                )
                event.save!

                course_uuid = course_uuids.sample

                course_sequence_number = CourseSequenceNumber.lock.find_by(course_uuid: course_uuid)
                course_sequence_number.sequence_number += 1
                course_sequence_number.save!

                puts "  lock #{thread_num} #{loop_num} #{course_sequence_number.course_uuid} #{course_sequence_number.sequence_number}"

                course_event = CourseEvent.new(
                  uuid:            SecureRandom.uuid.to_s,
                  course_uuid:     course_uuid,
                  sequence_number: course_sequence_number.sequence_number,
                  event:           event,
                )
                course_event.save!
              end
            rescue ActiveRecord::StatementInvalid => err
              num_retries += 1
              puts "  retry #{thread_num} #{loop_num}"
              retry
            end
          end
          puts "end #{thread_num} #{loop_num}"
        end
      end
    end

    start = Time.now
    wait_for_it = false
    threads.map(&:join)

    finish = Time.now

    elapsed        = finish - start
    num_events     = num_threads * num_loops
    events_per_sec = num_events / elapsed
    sec_per_event  = 1.0 / events_per_sec
    events_per_sec_per_thread = events_per_sec / num_threads
    sec_per_event_per_thread  = 1.0 / events_per_sec_per_thread

    puts "num_threads               = #{num_threads}"
    puts "num_loops                 = #{num_loops}"
    puts "num_courses               = #{num_courses}"
    puts "elapsed                   = #{elapsed}"
    puts "num events                = #{num_events}"
    puts "events_per_sec            = #{events_per_sec}"
    puts "sec_per_event             = #{sec_per_event}"
    puts "events_per_sec_per_thread = #{events_per_sec_per_thread}"
    puts "sec_per_event_per_thread  = #{sec_per_event_per_thread}"
    puts "num_retries               = #{num_retries}"
  end
end
