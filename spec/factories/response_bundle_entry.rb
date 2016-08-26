FactoryGirl.define do
  factory :response_bundle_entry do
    response_uuid         SecureRandom.uuid.to_s
    response_bundle_uuid  SecureRandom.uuid.to_s
  end
end
