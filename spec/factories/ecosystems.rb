FactoryGirl.define do
  factory :ecosystem do
    uuid { SecureRandom.uuid }
    book
  end
end
