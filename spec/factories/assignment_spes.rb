FactoryBot.define do
  factory :assignment_spe do
    uuid             { SecureRandom.uuid }
    calculation_uuid { SecureRandom.uuid }
    assignment_uuid  { SecureRandom.uuid }
    algorithm_name   { Faker::Hacker.abbreviation }
    exercise_uuids   { [] }
    spy_info         { {} }
  end
end
