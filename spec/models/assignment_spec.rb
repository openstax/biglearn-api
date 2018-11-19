require 'rails_helper'

RSpec.describe Assignment, type: :model do
  subject { FactoryGirl.create :assignment }

  it { is_expected.to have_many :assignment_pes }
  it { is_expected.to have_many :assignment_spes }
end
