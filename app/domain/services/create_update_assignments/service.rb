class Services::CreateUpdateAssignments::Service
  def process(assignments:)
    create_assignments(assignments: assignments)

    updated_assignments = assignments.map do |assignment|
      assignment.slice(:assignment_uuid, :sequence_number)
    end

    { updated_assignments: updated_assignments }
  end

  protected

  def create_assignments(assignments:)
    assignment_models = assignments.map do |assignment_hash|
      Assignment.new(
        uuid: SecureRandom.uuid,
        assignment_uuid: assignment_hash[:assignment_uuid],
        sequence_number: assignment_hash[:sequence_number],
        is_deleted: assignment_hash[:is_deleted],
        ecosystem_uuid: assignment_hash[:ecosystem_uuid],
        student_uuid: assignment_hash[:student_uuid],
        assignment_type: assignment_hash[:assignment_type],
        assigned_book_container_uuids: assignment_hash[:assigned_book_container_uuids],
        goal_num_tutor_assigned_spes: assignment_hash[:goal_num_tutor_assigned_spes],
        spes_are_assigned: assignment_hash[:spes_are_assigned],
        goal_num_tutor_assigned_pes: assignment_hash[:goal_num_tutor_assigned_pes],
        pes_are_assigned: assignment_hash[:pes_are_assigned]
      )
    end

    Assignment.transaction(isolation: :serializable) do
      result = Assignment.import assignment_models, on_duplicate_key_ignore: true
      imported_assignment_models = (assignment_models - result.failed_instances)
      assignment_models_by_assignment_uuid = imported_assignment_models.index_by(&:assignment_uuid)
      imported_assignment_uuids = assignment_models_by_assignment_uuid.keys
      imported_assignments = assignments.select do |assignment|
        imported_assignment_uuids.include?(assignment[:assignment_uuid])
      end
      assigned_exercise_models = imported_assignments.flat_map do |assignment_hash|
        assignment = assignment_models_by_assignment_uuid[assignment_hash[:assignment_uuid]]

        assignment_hash[:assigned_exercises].map do |assigned_exercise_hash|
          AssignedExercise.new(
            uuid: SecureRandom.uuid,
            assignment: assignment,
            trial_uuid: assigned_exercise_hash[:trial_uuid],
            exercise_uuid: assigned_exercise_hash[:exercise_uuid],
            is_spe: assigned_exercise_hash[:is_spe],
            is_pe: assigned_exercise_hash[:is_pe]
          )
        end
      end

      AssignedExercise.import assigned_exercise_models
    end
  end
end
