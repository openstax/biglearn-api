FactoryGirl.define do
  factory :assignment_spe do
    uuid            { SecureRandom.uuid }
    assignment_uuid { SecureRandom.uuid }
    algorithm_name  { Faker::Hacker.abbreviation }
    exercise_uuids  []
  end
end
