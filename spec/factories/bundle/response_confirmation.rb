FactoryGirl.define do
  factory :bundle_response_confirmation, class: Bundle::ResponseConfirmation do
    transient do
      for_bundle  false
    end

    bundle_uuid { SecureRandom.uuid.to_s }

    after(:build) do |bundle_response_confirmation, evaluator|
      if evaluator.for_bundle
        bundle_response_confirmation.bundle_uuid = evaluator.for_bundle.uuid
      end
    end
  end
end
