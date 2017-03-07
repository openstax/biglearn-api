require 'rails_helper'

RSpec.describe StudentPe, type: :model do
  subject { FactoryGirl.create :student_pe }

  it { is_expected.to validate_presence_of :student_uuid }
  it { is_expected.to validate_presence_of :algorithm_name }

  it { is_expected.to validate_uniqueness_of(:algorithm_name).scoped_to(:student_uuid) }
end
