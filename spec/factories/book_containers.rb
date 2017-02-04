FactoryGirl.define do
  factory :book_container do
    uuid { SecureRandom.uuid }
  end
end
