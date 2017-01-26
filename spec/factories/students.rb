FactoryGirl.define do
  factory :student do
    uuid { SecureRandom.uuid }
    course
  end
end
