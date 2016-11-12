namespace :event do
  desc "initialize CourseSequenceNumbers (num_courses)"
  task :setup, [:num_courses] => :environment do |t, args|
    num_courses = Integer(args[:num_courses])

    num_courses.times do |index|
      course_uuid = SecureRandom.uuid.to_s

      CourseSequenceNumber.create!(
        course_uuid: course_uuid,
        sequence_number: 0,
      )

      puts "#{index}: #{course_uuid}"
    end
  end
end
