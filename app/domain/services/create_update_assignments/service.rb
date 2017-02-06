class Services::CreateUpdateAssignments::Service
  def process(assignments:)
    assignment_attributes = []
    course_event_attributes = []
    updated_assignments = assignments.map do |assignment|
      assignment_attributes << { uuid: assignment[:assignment_uuid] }
      course_event_attributes << {
        # Can't use the assignment_uuid here because
        # there can be multiple updates for the same assignment_uuid
        uuid: SecureRandom.uuid,
        type: :create_update_assignment,
        course_uuid: assignment[:course_uuid],
        sequence_number: assignment[:sequence_number],
        data: assignment.slice(
          :assignment_uuid,
          :is_deleted,
          :ecosystem_uuid,
          :student_uuid,
          :assignment_type,
          :exclusion_info,
          :assigned_book_container_uuids,
          :goal_num_tutor_assigned_spes,
          :spes_are_assigned,
          :goal_num_tutor_assigned_pes,
          :pes_are_assigned,
          :assigned_exercises
        )
      }

      assignment.slice(:assignment_uuid, :sequence_number)
    end

    CourseEvent.transaction(isolation: :serializable) do
      Assignment.append assignment_attributes

      CourseEvent.append course_event_attributes
    end

    { updated_assignments: updated_assignments }
  end
end
