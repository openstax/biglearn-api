FactoryGirl.define do
  factory :student_clue do
    transient           { sorted_random_values { [rand, rand, rand].sort } }

    uuid                { SecureRandom.uuid }
    student_uuid        { SecureRandom.uuid }
    book_container_uuid { SecureRandom.uuid }
    algorithm_name      { Faker::Hacker.abbreviation }
    data                do
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
