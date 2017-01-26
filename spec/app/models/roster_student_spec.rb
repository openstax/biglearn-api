require 'rails_helper'

RSpec.describe RosterStudent, type: :model do
  subject(:roster_student) { FactoryGirl.create(:roster_student) }

  it { is_expected.to belong_to :course_roster }
  it { is_expected.to belong_to :roster_container }
  it { is_expected.to belong_to :student }

  it { is_expected.to have_one :course }

  it { is_expected.to validate_presence_of :course_roster }
  it { is_expected.to validate_presence_of :roster_container }
  it { is_expected.to validate_presence_of :student }

  it do
    is_expected.to(
      validate_uniqueness_of(:student_uuid).scoped_to(:roster_container_uuid).case_insensitive
    )
  end

  it 'validates that the roster_container belongs to the same course_roster' do
    expect(roster_student).to be_valid
    roster_student.roster_container = FactoryGirl.create :roster_container
    expect(roster_student).not_to be_valid
    expect(roster_student.errors.first).to(
      eq [:roster_container, 'must belong to the same course_roster']
    )
  end

  it 'validates that the roster and student belong to the same course' do
    expect(roster_student).to be_valid
    roster_student.student = FactoryGirl.create :student
    expect(roster_student).not_to be_valid
    expect(roster_student.errors.first).to(
      eq [:course_uuid, 'must be the same for the course_roster and student']
    )
  end
end
