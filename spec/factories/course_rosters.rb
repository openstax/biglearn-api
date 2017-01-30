FactoryGirl.define do
  factory :course_roster do
    uuid            { SecureRandom.uuid }
    course
    sequence_number { (course.course_rosters.maximum(:sequence_number) || -1) + 1 }
  end
end
