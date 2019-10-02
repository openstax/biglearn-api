require 'rails_helper'

RSpec.describe Ecosystem, type: :model do
  subject { FactoryBot.create :ecosystem }

  it { is_expected.to have_many :ecosystem_events }
  it { is_expected.to have_many :book_containers }

  it { is_expected.to validate_uniqueness_of(:metadata_sequence_number) }

  it do
    is_expected.to(
      validate_numericality_of(:metadata_sequence_number)
        .only_integer.is_greater_than_or_equal_to(0)
    )
  end

  it { is_expected.to validate_presence_of(:sequence_number) }
end
