FactoryGirl.define do
  factory :course do
    uuid { SecureRandom.uuid }
    ecosystem
  end
end
