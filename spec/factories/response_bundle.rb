FactoryGirl.define do
  factory :response_bundle do
    uuid            { SecureRandom.uuid.to_s }
    is_open         { [true,false].sample }
    partition_value { Kernel::rand(1000) }
  end
end
