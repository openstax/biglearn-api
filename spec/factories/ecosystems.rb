FactoryBot.define do
  factory :ecosystem do
    uuid            { SecureRandom.uuid }
    sequence_number { 0 }

    after(:create) { |ecosystem| ecosystem.reload }
  end
end
