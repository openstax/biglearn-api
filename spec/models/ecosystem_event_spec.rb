require 'rails_helper'

RSpec.describe EcosystemEvent, type: :model do
  subject { FactoryGirl.create :ecosystem_event }

  it { is_expected.to belong_to :ecosystem }

  it { is_expected.to validate_presence_of :ecosystem_uuid }
  it { is_expected.to validate_presence_of :sequence_number }
  it { is_expected.to validate_presence_of :type }

  it do
    is_expected.to(
      validate_uniqueness_of(:sequence_number).scoped_to(:ecosystem_uuid).case_insensitive
    )
  end

  it do
    is_expected.to(
      validate_numericality_of(:sequence_number).only_integer.is_greater_than_or_equal_to(0)
    )
  end
end
