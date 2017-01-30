require 'rails_helper'

RSpec.describe EcosystemPreparation, type: :model do
  subject { FactoryGirl.create :ecosystem_preparation }

  it { is_expected.to belong_to :course }
  it { is_expected.to belong_to :ecosystem }

  it { is_expected.to have_one :ecosystem_update }

  it { is_expected.to validate_presence_of :course_uuid }
  it { is_expected.to validate_presence_of :ecosystem_uuid }
  it { is_expected.to validate_presence_of :sequence_number }

  it { is_expected.to validate_uniqueness_of(:sequence_number).scoped_to(:course_uuid) }
end
