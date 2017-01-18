require 'rails_helper'

RSpec.describe Book, type: :model do
  subject { FactoryGirl.create :book }

  it { is_expected.to have_many :ecosystems }

  it { is_expected.to have_many :book_containers }
  it { is_expected.to have_many :exercise_pools }
end
