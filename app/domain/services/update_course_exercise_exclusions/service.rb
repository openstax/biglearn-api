class Services::UpdateCourseExerciseExclusions::Service
  def process(request_uuid:, course_uuid:, sequence_number:, exclusions:)
    excluded_exercise_uuids = exclusions.map{ |hash| hash[:exercise_uuid] }.compact
    excluded_exercise_group_uuids = exclusions.map{ |hash| hash[:exercise_group_uuid] }.compact

    exercise_exclusion = CourseExerciseExclusion.new(
      uuid:                          request_uuid,
      course_uuid:                   course_uuid,
      sequence_number:               sequence_number,
      excluded_exercise_uuids:       excluded_exercise_uuids,
      excluded_exercise_group_uuids: excluded_exercise_group_uuids
    )

    CourseExerciseExclusion.transaction(isolation: :serializable) do
      CourseExerciseExclusion.import [exercise_exclusion], on_duplicate_key_ignore: true
    end

    { status: 'success' }
  end
end
