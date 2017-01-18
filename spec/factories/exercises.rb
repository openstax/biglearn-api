FactoryGirl.define do
  factory :ecosystem_exercise do
    uuid              { SecureRandom.uuid }
    exercises_uuid    { SecureRandom.uuid }
    exercises_version { rand(10) }
  end
end
