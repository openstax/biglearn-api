FactoryGirl.define do
  factory :teacher_clue do
    transient             { sorted_random_values { [rand, rand, rand].sort } }

    uuid                  { SecureRandom.uuid }
    course_container_uuid { SecureRandom.uuid }
    book_container_uuid   { SecureRandom.uuid }
    data                  do
      {
        minimum:        sorted_random_values.first,
        most_likely:    sorted_random_values.second,
        maximum:        sorted_random_values.last,
        is_real:        [true, false].sample,
        ecosystem_uuid: SecureRandom.uuid
      }
    end
  end
end
