FactoryGirl.define do
  factory :x_test1 do
    uuid { SecureRandom.uuid.to_s }
  end
end
