FactoryGirl.define do
  factory :assignment do
    uuid                          { SecureRandom.uuid }
    assignment_uuid               { SecureRandom.uuid }
    sequence_number               do
      (Assignment.where(assignment_uuid: assignment_uuid).maximum(:sequence_number) || -1) + 1
    end
    is_deleted                    { [true, false].sample }
    ecosystem
    course_student
    assignment_type               { ['reading', 'homework', 'extra'].sample }
    opens_at                      { Time.now.yesteday }
    due_at                        { Time.now.tomorrow }
    assigned_book_container_uuids []
    goal_num_tutor_assigned_spes  { rand(2) + 1 }
    spes_are_assigned             { [true, false].sample }
    goal_num_tutor_assigned_pes   1
    pes_are_assigned              { [true, false].sample }
  end
end
