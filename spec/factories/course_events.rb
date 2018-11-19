FactoryGirl.define do
  factory :course_event do
    uuid            { SecureRandom.uuid }
    course
    sequence_number do
      (CourseEvent.where(course_uuid: course_uuid).maximum(:sequence_number) || -1) + 1
    end
    type            { CourseEvent.types.keys.sample }
    data            { {} }

    after(:build)   do |course_event|
      course_event.course ||= build(
        :course, uuid: course_event.course_uuid, sequence_number: course_event.sequence_number + 1
      )
      course_event.course.sequence_number = [
        course_event.course.sequence_number, course_event.sequence_number + 1
      ].max
    end
  end
end
