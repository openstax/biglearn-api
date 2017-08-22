require 'rails_helper'

RSpec.describe Ecosystem, type: :model do
  subject { FactoryGirl.create :ecosystem }

  it { is_expected.to validate_uniqueness_of(:metadata_sequence_number) }

  it do
    is_expected.to(
      validate_numericality_of(:metadata_sequence_number)
        .only_integer.is_greater_than_or_equal_to(0)
    )
  end
end
