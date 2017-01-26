FactoryGirl.define do
  factory :roster_container do
    uuid             { SecureRandom.uuid }
    course_roster
    course_container { build(:course_container, course: course_roster.course) }
  end
end
