FactoryGirl.define do
  factory :response do
    uuid           { SecureRandom.uuid }
    trial_uuid     { SecureRandom.uuid }
    trial_sequence { rand(10) }
    learner_uuid   { SecureRandom.uuid }
    question_uuid  { SecureRandom.uuid }
    is_correct     { [true, false].sample }
    responded_at   { Time.now }
  end
end
