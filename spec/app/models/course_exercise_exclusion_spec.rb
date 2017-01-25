require 'rails_helper'

RSpec.describe CourseExerciseExclusion, type: :model do
  subject { FactoryGirl.create :course_exercise_exclusion }

  it { is_expected.to belong_to :course }

  it { is_expected.to validate_presence_of :course_uuid }
  it { is_expected.to validate_presence_of :sequence_number }

  it do
    is_expected.to validate_uniqueness_of(:sequence_number).scoped_to(:course_uuid).case_insensitive
  end

  it { is_expected.to validate_numericality_of(:sequence_number).is_greater_than_or_equal_to(0) }
end
