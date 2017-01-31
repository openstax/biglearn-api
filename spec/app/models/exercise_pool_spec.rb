require 'rails_helper'

RSpec.describe ExercisePool, type: :model do
  subject { FactoryGirl.create :exercise_pool }

  it { is_expected.to belong_to :book_container }

  it { is_expected.to have_one :book }

  it { is_expected.to validate_presence_of :book_container }
end
