FactoryGirl.define do
  factory :course_event do
    uuid        { SecureRandom.uuid }
    type        { CourseEvent::VALID_EVENT_TYPES.sample }
    course
    sequence    :sequence_number, 0
    cached_json '{}'
  end
end
