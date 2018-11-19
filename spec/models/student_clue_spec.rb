require 'rails_helper'

RSpec.describe StudentClue, type: :model do
  subject(:student_clue) { FactoryGirl.create :student_clue }

  it { is_expected.to belong_to :student }
  it { is_expected.to belong_to :book_container }

  it { is_expected.to validate_presence_of :student_uuid }
  it { is_expected.to validate_presence_of :book_container_uuid }
  it { is_expected.to validate_presence_of :algorithm_name }
  it { is_expected.to validate_presence_of :data }

  it do
    is_expected.to(
      validate_uniqueness_of(:algorithm_name).scoped_to(:student_uuid, :book_container_uuid)
                                             .case_insensitive
    )
  end
end
