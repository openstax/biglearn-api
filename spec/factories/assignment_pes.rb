FactoryGirl.define do
  factory :assignment_pe do
    uuid           { SecureRandom.uuid }
    assignment
    exercise_uuids []
  end
end
