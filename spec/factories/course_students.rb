FactoryGirl.define do
  factory :course_student do
    association :container, factory: :course_container

    student_uuid { SecureRandom.uuid }
  end
end
