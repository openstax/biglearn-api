FactoryGirl.define do
  factory :course do
    uuid                   { SecureRandom.uuid }
    sequence_number        0

    after(:create) { |course| course.reload }
  end
end
