FactoryGirl.define do
  factory :assignment_pe do
    uuid            { SecureRandom.uuid }
    assignment_uuid { SecureRandom.uuid }
    exercise_uuids  []
  end
end
