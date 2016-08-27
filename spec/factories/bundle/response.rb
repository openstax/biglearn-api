FactoryGirl.define do
  factory :bundle_response, class: Bundle::Response do
    transient do
      for_response  false
    end

    uuid            { SecureRandom.uuid.to_s }
    partition_value { Kernel::rand(1000) }

    after(:build) do |bundle_response, evaluator|
      if evaluator.for_response
        bundle_response.uuid = evaluator.for_response.uuid
      end
    end
  end
end
