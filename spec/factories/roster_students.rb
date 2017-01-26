FactoryGirl.define do
  factory :roster_student do
    uuid             { SecureRandom.uuid }
    course_roster
    roster_container { build :roster_container, course_roster: course_roster }
    student          { build :student, course: roster_container.course }
  end
end
