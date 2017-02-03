FactoryGirl.define do
  factory :course_event do
    uuid            { SecureRandom.uuid }
    course_uuid     { SecureRandom.uuid }
    sequence_number do
      (CourseEvent.where(course_uuid: course_uuid).maximum(:sequence_number) || -1) + 1
    end
    event_type      { CourseEvent.event_types.keys.sample }
    data            { {} }
  end
end
