require 'rails_helper'

RSpec.describe CourseRoster, type: :model do
  subject { FactoryGirl.create(:course_roster) }

  it { is_expected.to belong_to :course }

  it { is_expected.to have_many :roster_containers }
  it { is_expected.to have_many :course_containers }

  it { is_expected.to have_many :roster_students }
  it { is_expected.to have_many :students }

  it { is_expected.to validate_presence_of :course_uuid }
  it { is_expected.to validate_presence_of :sequence_number }

  it do
    is_expected.to validate_uniqueness_of(:sequence_number).scoped_to(:course_uuid).case_insensitive
  end

  it { is_expected.to validate_numericality_of(:sequence_number).is_greater_than_or_equal_to(0) }
end
