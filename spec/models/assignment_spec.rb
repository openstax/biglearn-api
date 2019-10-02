require 'rails_helper'

RSpec.describe Assignment, type: :model do
  subject { FactoryBot.create :assignment }

  it { is_expected.to have_many :assignment_pes }
  it { is_expected.to have_many :assignment_spes }
end
