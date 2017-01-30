FactoryGirl.define do
  factory :student_clue do
    transient          { sorted_random_values { [rand, rand, rand].sort } }

    uuid               { SecureRandom.uuid }
    student
    book_container

    aggregate          { sorted_random_values.second }
    confidence_left    { sorted_random_values.first }
    confidence_right   { sorted_random_values.last }
    sample_size        { rand(10) }
    is_confidence_good { [true, false].sample }
    is_level_high      { [true, false].sample }
    is_above_threshold { [true, false].sample }
  end
end
