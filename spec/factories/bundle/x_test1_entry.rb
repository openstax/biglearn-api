FactoryGirl.define do
  factory :bundle_record_entry, class: Bundle::XTest1Entry do
    uuid           { SecureRandom.uuid.to_s }
    bundle_uuid    { SecureRandom.uuid.to_s }
  end
end
