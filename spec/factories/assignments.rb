FactoryGirl.define do
  factory :assignment do
    uuid { SecureRandom.uuid }
  end
end
