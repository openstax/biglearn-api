require 'rails_helper'

RSpec.describe GlobalExerciseExclusion, type: :model do
  subject { FactoryGirl.create :global_exercise_exclusion }

  it { is_expected.to validate_presence_of :sequence_number }

  it { is_expected.to validate_uniqueness_of(:sequence_number) }

  it { is_expected.to validate_numericality_of(:sequence_number).is_greater_than_or_equal_to(0) }
end
