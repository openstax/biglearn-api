require 'rails_helper'

RSpec.describe BookContainer, type: :model do
  subject { FactoryBot.create :book_container }

  it { is_expected.to belong_to :ecosystem }

  it { is_expected.to have_many :student_clues }
  it { is_expected.to have_many :teacher_clues }

  it { is_expected.to validate_presence_of :ecosystem_uuid }
end
