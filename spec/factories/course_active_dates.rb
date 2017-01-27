FactoryGirl.define do
  factory :course_active_date do
    uuid            { SecureRandom.uuid }
    course
    sequence_number { rand(10) }
    starts_at       { Time.now.yesterday }
    ends_at         { Time.now.tomorrow }
  end
end
