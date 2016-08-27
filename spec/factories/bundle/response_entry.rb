FactoryGirl.define do
  factory :bundle_response_entry, class: Bundle::ResponseEntry do
    uuid           { SecureRandom.uuid.to_s }
    bundle_uuid    { SecureRandom.uuid.to_s }
  end
end
