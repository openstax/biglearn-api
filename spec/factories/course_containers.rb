FactoryGirl.define do
  factory :course_container do
    uuid { SecureRandom.uuid }
    course
  end
end
