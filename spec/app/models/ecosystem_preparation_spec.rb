require 'rails_helper'

RSpec.describe EcosystemPreparation, type: :model do
  subject { FactoryGirl.create :ecosystem_preparation }

  it { is_expected.to belong_to :course }
  it { is_expected.to belong_to :ecosystem }

  it { is_expected.to have_one :ecosystem_update }

  it { is_expected.to validate_presence_of :course_uuid }
  it { is_expected.to validate_presence_of :ecosystem_uuid }
  it { is_expected.to validate_presence_of :sequence_number }

  it do
    is_expected.to validate_uniqueness_of(:sequence_number).scoped_to(:course_uuid).case_insensitive
  end

  it { is_expected.to validate_numericality_of(:sequence_number).is_greater_than_or_equal_to(0) }
end
