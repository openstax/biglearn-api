require 'rails_helper'

RSpec.describe TeacherClue, type: :model do
  subject(:teacher_clue) { FactoryGirl.create :teacher_clue }

  it { is_expected.to belong_to :course_container }
  it { is_expected.to belong_to :book_container }

  it { is_expected.to validate_presence_of :course_container_uuid }
  it { is_expected.to validate_presence_of :book_container_uuid }
  it { is_expected.to validate_presence_of :algorithm_name }
  it { is_expected.to validate_presence_of :data }

  it do
    is_expected.to(
      validate_uniqueness_of(:algorithm_name)
        .scoped_to(:course_container_uuid, :book_container_uuid)
        .case_insensitive
    )
  end
end
