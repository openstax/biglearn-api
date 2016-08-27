FactoryGirl.define do
  factory :bundle_response_bundle, class: Bundle::ResponseBundle do
    transient do
      for_bundle_responses  []
    end

    uuid            { SecureRandom.uuid.to_s }
    partition_value { Kernel::rand(10000)}

    after(:build) do |bundle_response_bundle, evaluator|
      evaluator.for_bundle_responses.each do |bundle_response|
        create(:bundle_response_entry,
          uuid:        bundle_response.uuid,
          bundle_uuid: bundle_response_bundle.uuid,
        )
      end
    end
  end
end
