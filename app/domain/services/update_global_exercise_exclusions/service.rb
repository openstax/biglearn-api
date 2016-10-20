class Services::UpdateGlobalExerciseExclusions::Service
  def process(update_uuid:, sequence_number:, exclusions:)

    exercise_exclusions_update = GlobalExerciseExclusionUpdate.new(
      :update_uuid      => update_uuid,
      :sequence_number  => sequence_number,
    )

    exercise_exclusions = exclusions.map{ |exclusion|
      GlobalExerciseExclusion.new(
        :update_uuid      => update_uuid,
        :excluded_uuid    => exclusion.values_at('exercise_uuid', 'exercise_group_uuid').compact.first
      )
    }

    ActiveRecord::Base.transaction(isolation: :serializable) do
      GlobalExerciseExclusionUpdate.import [exercise_exclusions_update]
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
