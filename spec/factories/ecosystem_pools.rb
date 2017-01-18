FactoryGirl.define do
  factory :ecosystem_pool do
    uuid                                      { SecureRandom.uuid }
    ecosystem_container
    use_for_clue                              { [true, false].sample }
    use_for_personalized_for_assignment_types []
    exercise_uuids                            []
  end
end
