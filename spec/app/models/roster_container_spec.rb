require 'rails_helper'

RSpec.describe RosterContainer, type: :model do
  subject(:roster_container) { FactoryGirl.create(:roster_container) }

  it { is_expected.to belong_to :course_roster }
  it { is_expected.to have_one :course }

  it { is_expected.to belong_to :course_container }

  it { is_expected.to belong_to :parent_roster_container }
  it { is_expected.to have_many :child_roster_containers }

  it { is_expected.to have_many :roster_students }
  it { is_expected.to have_many :students }

  it { is_expected.to validate_presence_of :course_roster }
  it { is_expected.to validate_presence_of :course_container }

  it do
    is_expected.to validate_uniqueness_of(:container_uuid).scoped_to(:roster_uuid).case_insensitive
  end

  it 'validates that the roster and container belong to the same course' do
    expect(roster_container).to be_valid
    roster_container.course_container = FactoryGirl.create :course_container
    expect(roster_container).not_to be_valid
    expect(roster_container.errors.first).to(
      eq [:course_uuid, 'must be the same for the course_roster and course_container']
    )
  end
end
