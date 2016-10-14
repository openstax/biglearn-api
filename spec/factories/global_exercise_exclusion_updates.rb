FactoryGirl.define do
  factory :global_exercise_exclusion_update do
    update_uuid     { SecureRandom.uuid.to_s }

    sequence_number { Kernel::rand(10) }
  end
end
