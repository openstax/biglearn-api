FactoryGirl.define do
  factory :ecosystem_preparation do
    uuid { SecureRandom.uuid }
    course
    ecosystem
  end
end
