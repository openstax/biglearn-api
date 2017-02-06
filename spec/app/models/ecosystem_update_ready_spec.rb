require 'rails_helper'

RSpec.describe EcosystemUpdateReady, type: :model do
  subject { FactoryGirl.create :ecosystem_update_ready }

  it { is_expected.to validate_presence_of :preparation_uuid }

  it { is_expected.to validate_uniqueness_of(:preparation_uuid).case_insensitive }
end
