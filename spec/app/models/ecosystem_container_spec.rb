require 'rails_helper'

RSpec.describe EcosystemContainer, type: :model do
  subject { FactoryGirl.create :ecosystem_container }

  it { is_expected.to belong_to :ecosystem }
  it { is_expected.to belong_to :parent_ecosystem_container }

  it { is_expected.to have_many :child_ecosystem_containers }
  it { is_expected.to have_many :ecosystem_pools }

  it { is_expected.to validate_presence_of :ecosystem }
end
