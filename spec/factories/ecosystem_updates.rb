FactoryGirl.define do
  factory :ecosystem_update do
    uuid        { SecureRandom.uuid }
    ecosystem_preparation
  end
end
