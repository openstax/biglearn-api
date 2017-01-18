FactoryGirl.define do
  factory :ecosystem_container do
    uuid         { SecureRandom.uuid }
    ecosystem
    cnx_identity { "#{SecureRandom.uuid}@#{rand(10)}.#{rand(10)}" }
  end
end
