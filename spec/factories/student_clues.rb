FactoryGirl.define do
  factory :student_clue do
    transient           { sorted_random_values { [rand, rand, rand].sort } }

    uuid                { SecureRandom.uuid }
    student_uuid        { SecureRandom.uuid }
    book_container_uuid { SecureRandom.uuid }

    aggregate           { sorted_random_values.second }
    confidence_left     { sorted_random_values.first }
    confidence_right    { sorted_random_values.last }
    sample_size         { rand(10) }
    is_good_confidence  { [true, false].sample }
    is_high_level       { [true, false].sample }
    is_above_threshold  { [true, false].sample }
  end
end
