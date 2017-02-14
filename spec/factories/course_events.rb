FactoryGirl.define do
  factory :course_event do
    uuid            { SecureRandom.uuid }
    course_uuid     { SecureRandom.uuid }
    sequence_number do
      (CourseEvent.where(course_uuid: course_uuid).maximum(:sequence_number) || -1) + 1
    end
    type            { CourseEvent.types.keys.sample }
    data            { {} }
  end
end
