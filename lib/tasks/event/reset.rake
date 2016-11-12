namespace :event do
  desc "reset Events, CourseEvents, and CourseSequenceNumbers"
  task :reset => :environment do
    puts "destroying Events..."
    ExperOneEvent.find_each do |event|
      event.destroy!
    end
    ExperTwoEvent.find_each do |event|
      event.destroy!
    end

    puts "destroying CourseEvents..."
    CourseEvent.find_each do |course_event|
      course_event.destroy!
    end

    puts "destroying CourseSequenceNumber..."
    CourseSequenceNumber.find_each do |course_sequence_number|
      course_sequence_number.sequence_number = 0
      course_sequence_number.save!
    end

    puts "done"
  end
end
