class Services::UpdateCourseExerciseExclusions::Service
  def process(course_uuid:, sequence_number:, exclusions:)

    unless Course.find_by uuid: course_uuid
      fail Errors::AppUnprocessableError.new("Course #{course_uuid} does not exist. Exclusions cannot be created.")
    end

    exercise_exclusions = exclusions.map{ |exclusion|
      CourseExerciseExclusion.new(
        :course_uuid      => course_uuid,
        :sequence_number  => sequence_number,
        :excluded_uuid    => exclusion.values_at('exercise_uuid', 'exercise_group_uuid').compact.first
      )
    }

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