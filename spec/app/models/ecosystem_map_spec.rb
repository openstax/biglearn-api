require 'rails_helper'

RSpec.describe EcosystemMap, type: :model do
  subject { FactoryGirl.create :ecosystem_map }

  it { is_expected.to belong_to :from_ecosystem }
  it { is_expected.to belong_to :to_ecosystem }

  it { is_expected.to validate_presence_of :from_ecosystem }
  it { is_expected.to validate_presence_of :to_ecosystem }

  it do
    is_expected.to(
      validate_uniqueness_of(:to_ecosystem_uuid).scoped_to(:from_ecosystem_uuid).case_insensitive
    )
  end
end
