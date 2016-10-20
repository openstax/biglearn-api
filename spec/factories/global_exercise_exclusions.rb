FactoryGirl.define do
  factory :global_exercise_exclusion do
    update_uuid       { SecureRandom.uuid.to_s }

    excluded_uuid     { SecureRandom.uuid.to_s }
  end
end
