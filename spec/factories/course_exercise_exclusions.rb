FactoryGirl.define do
  factory :course_exercise_exclusion do
    uuid                          { SecureRandom.uuid }
    course_uuid                   { SecureRandom.uuid }
    sequence_number               do
      (course&.course_exercise_exclusions&.maximum(:sequence_number) || -1) + 1
    end
    excluded_exercise_uuids       []
    excluded_exercise_group_uuids []
  end
end
