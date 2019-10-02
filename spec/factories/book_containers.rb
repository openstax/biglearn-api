FactoryBot.define do
  factory :book_container do
    uuid { SecureRandom.uuid }
    ecosystem
  end
end
