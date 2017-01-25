class Services::UpdateGlobalExerciseExclusions::Service
  def process(request_uuid:, sequence_number:, exclusions:)
    excluded_exercise_uuids = exclusions.map{ |hash| hash[:exercise_uuid] }.compact
    excluded_exercise_group_uuids = exclusions.map{ |hash| hash[:exercise_group_uuid] }.compact

    exercise_exclusion = GlobalExerciseExclusion.new(
      uuid:                          request_uuid,
      sequence_number:               sequence_number,
      excluded_exercise_uuids:       excluded_exercise_uuids,
      excluded_exercise_group_uuids: excluded_exercise_group_uuids
    )

    GlobalExerciseExclusion.transaction(isolation: :serializable) do
      GlobalExerciseExclusion.import [exercise_exclusion], on_duplicate_key_ignore: true
    end

    { status: 'success' }
  end
end
