require 'rails_helper'

RSpec.describe Assignment, type: :model do
  subject { FactoryGirl.create :assignment }

  it { is_expected.to belong_to :ecosystem }
  it { is_expected.to belong_to :student }

  it { is_expected.to have_many :assigned_exercises }
  it { is_expected.to have_many :exercises }

  it { is_expected.to have_one :assignment_pe }
  it { is_expected.to have_one :assignment_spe }

  it { is_expected.to validate_presence_of :assignment_uuid }
  it { is_expected.to validate_presence_of :sequence_number }
  it { is_expected.to validate_presence_of :ecosystem_uuid }
  it { is_expected.to validate_presence_of :student_uuid }
  it { is_expected.to validate_presence_of :assignment_type }
  it { is_expected.to validate_presence_of :goal_num_tutor_assigned_spes }
  it { is_expected.to validate_presence_of :goal_num_tutor_assigned_pes }

  it do
    is_expected.to(
      validate_uniqueness_of(:sequence_number).scoped_to(:assignment_uuid).case_insensitive
    )
  end
end
