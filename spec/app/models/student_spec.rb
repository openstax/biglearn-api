require 'rails_helper'

RSpec.describe Student, type: :model do
  subject { FactoryGirl.create(:student) }

  it { is_expected.to belong_to :course }

  it { is_expected.to have_many :roster_students }
  it { is_expected.to have_many :course_rosters }

  it { is_expected.to validate_presence_of :course_uuid }
end
