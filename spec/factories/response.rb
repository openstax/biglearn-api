FactoryGirl.define do
  factory :response do
    uuid            { SecureRandom.uuid.to_s }
    trial_uuid      { SecureRandom.uuid.to_s }
    trial_sequence  { Kernel::rand(10) }
    learner_uuid    { SecureRandom.uuid.to_s }
    question_uuid   { SecureRandom.uuid.to_s }
    is_correct      { [true,false].sample }
    responded_at    { Time.now }
  end
end
