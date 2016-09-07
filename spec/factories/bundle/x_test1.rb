FactoryGirl.define do
  factory :bundle_record, class: Bundle::XTest1 do
    transient do
      for_record  false
    end

    uuid            { SecureRandom.uuid.to_s }
    partition_value { Kernel::rand(10000) }

    after(:build) do |bundle_record, evaluator|
      if evaluator.for_record
        bundle_record.uuid = evaluator.for_record.uuid
      end
    end
  end
end
