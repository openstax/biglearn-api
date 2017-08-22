FactoryGirl.define do
  factory :course do
    uuid                   { SecureRandom.uuid }
    initial_ecosystem_uuid { SecureRandom.uuid }
  end
end
