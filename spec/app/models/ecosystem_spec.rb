require 'rails_helper'

RSpec.describe Ecosystem, type: :model do
  subject { FactoryGirl.create :ecosystem }

  it { is_expected.to have_many :ecosystem_containers }
  it { is_expected.to have_many :ecosystem_pools }
  it { is_expected.to have_many :ecosystem_preparations }
  it { is_expected.to have_many :ecosystem_updates }
end
