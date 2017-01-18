FactoryGirl.define do
  factory :book do
    uuid         { SecureRandom.uuid }
    cnx_identity { "#{SecureRandom.uuid}@#{rand(10)}.#{rand(10)}" }
  end
end
