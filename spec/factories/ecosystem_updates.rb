FactoryGirl.define do
  factory :ecosystem_update do
    uuid        { SecureRandom.uuid }
    ecosystem_preparation
    course
    ecosystem
  end
end
