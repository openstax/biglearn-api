require 'rails_helper'

RSpec.describe Ecosystem, type: :model do
  subject { FactoryGirl.create :ecosystem }

  it { is_expected.to belong_to :book }

  it { is_expected.to have_many :book_containers }
  it { is_expected.to have_many :exercise_pools }
  it { is_expected.to have_many :ecosystem_preparations }
  it { is_expected.to have_many :ecosystem_updates }

  it { is_expected.to validate_presence_of :book }
end
