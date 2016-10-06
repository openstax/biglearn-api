FactoryGirl.define do
  factory :course do
    uuid            { SecureRandom.uuid.to_s }
    ecosystem_uuid  { SecureRandom.uuid.to_s }
  end
end
