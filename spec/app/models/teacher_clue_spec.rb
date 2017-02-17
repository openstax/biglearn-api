require 'rails_helper'

RSpec.describe TeacherClue, type: :model do
  subject(:teacher_clue) { FactoryGirl.create :teacher_clue }

  it { is_expected.to validate_presence_of :course_container_uuid }
  it { is_expected.to validate_presence_of :book_container_uuid }
  it { is_expected.to validate_presence_of :data }
end
