FactoryGirl.define do
  factory :bundle_record_confirmation, class: Bundle::XTest1Confirmation do
    transient do
      for_bundle  false
    end

    bundle_uuid   { SecureRandom.uuid }
    receiver_uuid { SecureRandom.uuid }

    after(:build) do |bundle_record_confirmation, evaluator|
      if evaluator.for_bundle
        bundle_record_confirmation.bundle_uuid = evaluator.for_bundle.uuid
      end
    end
  end
end
