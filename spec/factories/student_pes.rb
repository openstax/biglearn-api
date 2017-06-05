FactoryGirl.define do
  factory :student_pe do
    uuid           { SecureRandom.uuid }
    student_uuid   { SecureRandom.uuid }
    algorithm_name { Faker::Hacker.abbreviation }
    exercise_uuids []
    spy_info       { {} }
  end
end
