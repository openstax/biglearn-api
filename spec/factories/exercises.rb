FactoryGirl.define do
  factory :exercise do
    uuid              { SecureRandom.uuid }
    exercises_uuid    { SecureRandom.uuid }
    exercises_version { rand(10) }
    los               []
  end
end
