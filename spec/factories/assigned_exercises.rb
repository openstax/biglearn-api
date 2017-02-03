FactoryGirl.define do
  factory :assigned_exercise do
    uuid            { SecureRandom.uuid }
    assignment
    trial_uuid      { SecureRandom.uuid }
    exercise
    is_spe          { [true, false].sample }
    is_pe           { [true, false].sample }
  end
end
