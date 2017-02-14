FactoryGirl.define do
  factory :student do
    uuid { SecureRandom.uuid }
  end
end
