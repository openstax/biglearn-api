class Services::UpdateGloballyExcludedExercises::Service
  def process(sequence_number:, exclusions:)

    excluded_exercises = exclusions.map{ |exclusion|
      ExcludedExercise.new(
        :sequence_number  => sequence_number,
        :excluded_uuid    => exclusion.values_at('exercise_uuid', 'exercise_group_uuid').compact.first
      )
    }

    ExcludedExercise.transaction(isolation: :serializable) do
      ExcludedExercise.import excluded_exercises
    end

    { 
      excluded_exercises: excluded_exercises.map{ |exercise|
        { excluded_uuid:  exercise.excluded_uuid }
      },
      sequence_number:    sequence_number
    }

  end
end
