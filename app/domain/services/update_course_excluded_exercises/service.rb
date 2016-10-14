class Services::UpdateCourseExcludedExercises::Service
  def process(course_uuid:, sequence_number:, exclusions:)

    unless Course.find_by uuid: course_uuid
      fail Errors::AppUnprocessableError.new("Course #{course_uuid} does not exist. Exclusions cannot be created.")
    end

    excluded_exercises = exclusions.map{ |exclusion|
      CourseExcludedExercise.new(
        :course_uuid      => course_uuid,
        :sequence_number  => sequence_number,
        :excluded_uuid    => exclusion.values_at('exercise_uuid', 'exercise_group_uuid').compact.first
      )
    }

    CourseExcludedExercise.transaction(isolation: :serializable) do
      CourseExcludedExercise.import excluded_exercises
    end

    { 
      excluded_exercises: excluded_exercises.map{ |exercise|
        { excluded_uuid:  exercise.excluded_uuid }
      },
      sequence_number:    sequence_number,
      course_uuid:        course_uuid
    }

  end
end