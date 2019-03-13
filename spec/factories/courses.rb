FactoryGirl.define do
  factory :course do
    uuid                   { SecureRandom.uuid }
    sequence_number        0
    initial_ecosystem_uuid { SecureRandom.uuid }
    after(:create) { |course| course.reload }
  end
end
