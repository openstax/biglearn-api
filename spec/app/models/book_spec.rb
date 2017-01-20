require 'rails_helper'

RSpec.describe Book, type: :model do
  subject { FactoryGirl.create :book }

  it { is_expected.to have_many :ecosystems }

  it { is_expected.to have_many :book_containers }
  it { is_expected.to have_many :exercise_pools }

  it { is_expected.to validate_presence_of :cnx_identity }
  it { is_expected.to validate_uniqueness_of :cnx_identity }
end
