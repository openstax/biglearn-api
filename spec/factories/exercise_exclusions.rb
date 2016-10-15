FactoryGirl.define do
  factory :exercise_exclusions, class: OpenStruct do
    transient do
      exclusions_count 10
      exclusions_any_count 5
      exclusions_specific_count 5
    end

    exclusions      {
                      (
                        exclusions_any_count.times
                          .map{ { 'exercise_group_uuid' => SecureRandom.uuid.to_s } } +
                        exclusions_specific_count.times
                          .map{ { 'exercise_group_uuid' => SecureRandom.uuid.to_s } }
                      ).shuffle
                    }
    uuids           {
                      exclusions.map{ |exclusion|
                        exclusion.values_at('exercise_uuid', 'exercise_group_uuid').compact.first
                      }
                    }

  end
end
