require 'rails_helper'

RSpec.describe StudentPe, type: :model do
  subject { FactoryBot.create :student_pe }

  it { is_expected.to belong_to(:student).optional }

  it { is_expected.to validate_presence_of :calculation_uuid }
  it { is_expected.to validate_presence_of :student_uuid }
  it { is_expected.to validate_presence_of :algorithm_name }

  it do
    is_expected.to(
      validate_uniqueness_of(:algorithm_name).scoped_to(:student_uuid).case_insensitive
    )
  end
end
