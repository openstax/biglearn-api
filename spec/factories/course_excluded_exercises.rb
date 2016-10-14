FactoryGirl.define do
  factory :course_excluded_exercise do
    sequence_number { Kernel::rand(10) }
    course_uuid     { SecureRandom.uuid.to_s }
    excluded_uuid   { SecureRandom.uuid.to_s }
  end
end
