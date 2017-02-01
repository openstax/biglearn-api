FactoryGirl.define do
  factory :student_pe do
    uuid           { SecureRandom.uuid }
    student
    exercise_uuids []
  end
end
