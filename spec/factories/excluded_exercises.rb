FactoryGirl.define do
  factory :excluded_exercise do
    sequence_number   { Kernel::rand(10) }
    excluded_uuid     { SecureRandom.uuid.to_s }
  end
end
