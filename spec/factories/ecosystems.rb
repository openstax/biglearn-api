FactoryGirl.define do
  factory :ecosystem do
    uuid            { SecureRandom.uuid.to_s }
  end
end
