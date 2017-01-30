require 'rails_helper'

RSpec.describe BookContainer, type: :model do
  subject { FactoryGirl.create :book_container }

  it { is_expected.to belong_to :book }
  it { is_expected.to belong_to :parent_book_container }

  it { is_expected.to have_many :child_book_containers }
  it { is_expected.to have_many :exercise_pools }

  it { is_expected.to have_many :student_clues }
  it { is_expected.to have_many :teacher_clues }

  it { is_expected.to validate_presence_of :book }
end
