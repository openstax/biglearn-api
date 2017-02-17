FactoryGirl.define do
  factory :book_container do
    uuid           { SecureRandom.uuid }
    ecosystem_uuid { SecureRandom.uuid }
  end
end
