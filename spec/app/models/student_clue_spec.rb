require 'rails_helper'

RSpec.describe StudentClue, type: :model do
  subject(:student_clue) { FactoryGirl.create :student_clue }

  it { is_expected.to validate_presence_of :student_uuid }
  it { is_expected.to validate_presence_of :book_container_uuid }
  it { is_expected.to validate_presence_of :data }
end
