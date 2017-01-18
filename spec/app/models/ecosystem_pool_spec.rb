require 'rails_helper'

RSpec.describe EcosystemPool, type: :model do
  subject { FactoryGirl.create :ecosystem_pool }

  it { is_expected.to belong_to :ecosystem_container }

  it { is_expected.to have_one :ecosystem }

  it { is_expected.to validate_presence_of :ecosystem_container }
end
