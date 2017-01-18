require 'rails_helper'

RSpec.describe Course, type: :model do
  subject { FactoryGirl.create :course }

  it { is_expected.to belong_to :ecosystem }

  it { is_expected.to have_many :ecosystem_preparations }
  it { is_expected.to have_many :ecosystem_updates }

  it { is_expected.to validate_presence_of :ecosystem }
end
