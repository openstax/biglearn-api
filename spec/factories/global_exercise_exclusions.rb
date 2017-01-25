FactoryGirl.define do
  factory :global_exercise_exclusion do
    uuid                          { SecureRandom.uuid }
    sequence_number               { (GlobalExerciseExclusion.maximum(:sequence_number) || -1) + 1 }
    excluded_exercise_uuids       []
    excluded_exercise_group_uuids []
  end
end
