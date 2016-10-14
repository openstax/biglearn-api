class Services::UpdateGlobalExerciseExclusions::Service
  def process(sequence_number:, exclusions:)

    exercise_exclusions = exclusions.map{ |exclusion|
      GlobalExerciseExclusion.new(
        :sequence_number  => sequence_number,
        :excluded_uuid    => exclusion.values_at('exercise_uuid', 'exercise_group_uuid').compact.first
      )
    }

    GlobalExerciseExclusion.transaction(isolation: :serializable) do
      GlobalExerciseExclusion.import exercise_exclusions
    end

    { 
      exercise_exclusions: exercise_exclusions.map{ |exercise|
        { excluded_uuid:  exercise.excluded_uuid }
      },
      sequence_number:    sequence_number
    }

  end
end
