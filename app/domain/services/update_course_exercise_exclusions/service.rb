class Services::UpdateCourseExerciseExclusions::Service
  def process(update_uuid:, sequence_number:, course_uuid:, exclusions:)

    unless Course.find_by uuid: course_uuid
      fail Errors::AppUnprocessableError.new("Course #{course_uuid} does not exist. Exclusions cannot be created.")
    end

    exercise_exclusions_update = CourseExerciseExclusionUpdate.new(
      :update_uuid      => update_uuid,
      :sequence_number  => sequence_number,
      :course_uuid      => course_uuid,
    )

    exercise_exclusions = exclusions.map{ |exclusion|
      CourseExerciseExclusion.new(
        :update_uuid      => update_uuid,
        :excluded_uuid    => exclusion.values_at('exercise_uuid', 'exercise_group_uuid').compact.first
      )
    }

    CourseExerciseExclusionUpdate.transaction(isolation: :serializable) do
      CourseExerciseExclusionUpdate.import [exercise_exclusions_update]
    end

    CourseExerciseExclusion.transaction(isolation: :serializable) do
      CourseExerciseExclusion.import exercise_exclusions
    end

    { 
      exercise_exclusions: exercise_exclusions.map{ |exercise|
        { excluded_uuid:  exercise.excluded_uuid }
      },
      sequence_number:    sequence_number,
      course_uuid:        course_uuid
    }

  end
end