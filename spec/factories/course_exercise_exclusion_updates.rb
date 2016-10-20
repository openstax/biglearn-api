FactoryGirl.define do
  factory :course_exercise_exclusion_update do
    update_uuid     { SecureRandom.uuid.to_s }

    sequence_number { Kernel::rand(10) }
    course_uuid     { SecureRandom.uuid.to_s }
  end
end
