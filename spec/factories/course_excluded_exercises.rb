FactoryGirl.define do
  factory :course_excluded_exercise do
    sequence_number { Kernel::rand(10) }
    excluded_uuid   { SecureRandom.uuid.to_s }
    course_uuid     { SecureRandom.uuid.to_s }
  end
end
