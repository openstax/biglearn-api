FactoryGirl.define do
  factory :bundle_record_entry, class: Bundle::XTest1Entry do
    uuid        { SecureRandom.uuid }
    bundle_uuid { SecureRandom.uuid }
  end
end
