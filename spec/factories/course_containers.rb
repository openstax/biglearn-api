FactoryGirl.define do
  factory :course_container do
    association :course, factory: :course

    container_uuid        { SecureRandom.uuid }
    parent_container_uuid { SecureRandom.uuid }
  end
end
