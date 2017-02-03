require 'rails_helper'

RSpec.describe AssignmentPe, type: :model do
  subject { FactoryGirl.create :assignment_pe }

  it { is_expected.to belong_to :assignment }

  it { is_expected.to validate_presence_of :assignment_uuid }
  it { is_expected.to validate_uniqueness_of(:assignment_uuid).case_insensitive }
end
