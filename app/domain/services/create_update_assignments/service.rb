class Services::CreateUpdateAssignments::Service < Services::ApplicationService
  def process(assignments:)
    assignment_attributes = []
    course_event_attributes = []
    updated_assignments = assignments.map do |assignment|
      assignment_attributes << { uuid: assignment.fetch(:assignment_uuid) }
      course_event_attributes << {
        # Can't use the assignment_uuid here because
        # there can be multiple updates for the same assignment_uuid
        uuid: assignment.fetch(:request_uuid),
        type: :create_update_assignment,
        course_uuid: assignment.fetch(:course_uuid),
        sequence_number: assignment.fetch(:sequence_number),
        data: assignment.slice(
          :request_uuid,
          :course_uuid,
          :sequence_number,
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
          :assigned_exercises,
          :created_at,
          :updated_at
        )
      }

      assignment.slice(:request_uuid)
                .merge(updated_assignment_uuid: assignment.fetch(:assignment_uuid))
    end

    CourseEvent.transaction do
      CourseEvent.append course_event_attributes

      Assignment.append assignment_attributes
    end

    { updated_assignments: updated_assignments }
  end
end
