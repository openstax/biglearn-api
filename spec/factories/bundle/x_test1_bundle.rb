FactoryGirl.define do
  factory :bundle_record_bundle, class: Bundle::XTest1Bundle do
    transient do
      for_bundle_records []
      confirmed_by       []
    end

    uuid            { SecureRandom.uuid }
    partition_value { Kernel::rand(10000) }

    after(:build) do |bundle_record_bundle, evaluator|
      evaluator.for_bundle_records.each do |bundle_record|
        create(:bundle_record_entry,
          uuid:        bundle_record.uuid,
          bundle_uuid: bundle_record_bundle.uuid,
        )
      end

      evaluator.confirmed_by.each do |receiver_uuid|
        create(:bundle_record_confirmation,
          receiver_uuid: receiver_uuid,
          for_bundle:    bundle_record_bundle,
        )
      end
    end
  end
end
