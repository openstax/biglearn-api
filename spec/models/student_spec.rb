require 'rails_helper'

RSpec.describe Student, type: :model do
  subject { FactoryBot.create :student }

  it { is_expected.to have_many :student_clues }
  it { is_expected.to have_many :student_pes }
end
