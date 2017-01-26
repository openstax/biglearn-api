require 'rails_helper'

RSpec.describe Exercise, type: :model do
  subject { FactoryGirl.create :exercise }

  it { is_expected.to have_many :assigned_exercises }

  it { is_expected.to validate_presence_of :exercises_uuid }
  it { is_expected.to validate_presence_of :exercises_version }

  it do
    is_expected.to(
      validate_uniqueness_of(:exercises_version).scoped_to(:exercises_uuid).case_insensitive
    )
  end
end
