require 'rails_helper'

RSpec.describe AssignedExercise, type: :model do
  subject { FactoryGirl.create :assigned_exercise }

  it { is_expected.to belong_to :assignment }
  it { is_expected.to belong_to :exercise }

  it { is_expected.to have_many :assigned_exercises }

  it { is_expected.to validate_presence_of :assignment }
  it { is_expected.to validate_presence_of :exercise_uuid }

  it do
    is_expected.to(
      validate_uniqueness_of(:exercise_uuid).scoped_to(:assignment_uuid).case_insensitive
    )
  end
end
