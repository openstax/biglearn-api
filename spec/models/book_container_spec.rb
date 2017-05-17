require 'rails_helper'

RSpec.describe BookContainer, type: :model do
  subject { FactoryGirl.create :book_container }

  it { is_expected.to validate_presence_of :ecosystem_uuid }
end
