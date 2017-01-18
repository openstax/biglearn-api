require 'rails_helper'

RSpec.describe EcosystemUpdate, type: :model do
  subject { FactoryGirl.create :ecosystem_update }

  it { is_expected.to belong_to :ecosystem_preparation }

  it { is_expected.to have_one :course }
  it { is_expected.to have_one :ecosystem }

  it { is_expected.to validate_presence_of :ecosystem_preparation }
end
