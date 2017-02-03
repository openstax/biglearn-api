FactoryGirl.define do
  factory :assignment_spe do
    uuid           { SecureRandom.uuid }
    assignment
    exercise_uuids []
  end
end
