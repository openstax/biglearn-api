FactoryGirl.define do
  factory :ecosystem_update_ready do
    uuid             { SecureRandom.uuid }
    preparation_uuid { SecureRandom.uuid }
  end
end
