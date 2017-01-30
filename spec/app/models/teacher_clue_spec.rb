require 'rails_helper'

RSpec.describe TeacherClue, type: :model do
  subject { FactoryGirl.create :teacher_clue }

  it { is_expected.to belong_to :course_container }
  it { is_expected.to belong_to :book_container }

  it { is_expected.to validate_presence_of :course_container_uuid }
  it { is_expected.to validate_presence_of :book_container_uuid }
  it { is_expected.to validate_presence_of :aggregate }
  it { is_expected.to validate_presence_of :confidence_left }
  it { is_expected.to validate_presence_of :confidence_right }
  it { is_expected.to validate_presence_of :sample_size }
  it { is_expected.to validate_presence_of :unique_learner_count }

  it do
    is_expected.to validate_uniqueness_of(:book_container_uuid).scoped_to(:course_container_uuid)
                                                               .case_insensitive
  end

  it do
    is_expected.to validate_numericality_of(:aggregate).is_greater_than_or_equal_to(0)
                                                       .is_less_than_or_equal_to(1)
  end
  it do
    is_expected.to validate_numericality_of(:confidence_left).is_greater_than_or_equal_to(0)
                                                             .is_less_than_or_equal_to(1)
  end
  it do
    is_expected.to validate_numericality_of(:confidence_right).is_greater_than_or_equal_to(0)
                                                              .is_less_than_or_equal_to(1)
  end
  it do
    is_expected.to validate_numericality_of(:sample_size).only_integer
                                                         .is_greater_than_or_equal_to(0)
  end
  it do
    is_expected.to validate_numericality_of(:unique_learner_count).only_integer
                                                                  .is_greater_than_or_equal_to(0)
  end
end
