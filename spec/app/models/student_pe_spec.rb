require 'rails_helper'

RSpec.describe StudentPe, type: :model do
  subject { FactoryGirl.create :student_pe }

  it { is_expected.to belong_to :student }

  it { is_expected.to validate_presence_of :student_uuid }
  it { is_expected.to validate_uniqueness_of(:student_uuid).case_insensitive }
end
