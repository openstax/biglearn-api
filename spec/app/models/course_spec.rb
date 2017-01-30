require 'rails_helper'

RSpec.describe Course, type: :model do
  subject(:course) { FactoryGirl.create :course }

  it { is_expected.to belong_to :ecosystem }

  it { is_expected.to have_many :ecosystem_preparations }
  it { is_expected.to have_many :ecosystem_updates }
  it { is_expected.to have_many :course_exercise_exclusions }

  it { is_expected.to have_many :course_rosters }
  it { is_expected.to have_many :course_containers }
  it { is_expected.to have_many :students }

  it { is_expected.to validate_presence_of :ecosystem_uuid }

  it 'can return its active ecosystem preparation' do
    expect(course.active_ecosystem_preparation).to be_nil

    prep_1 = FactoryGirl.create :ecosystem_preparation, course: course
    expect(course.active_ecosystem_preparation).to be_nil

    FactoryGirl.create :ecosystem_update, ecosystem_preparation: prep_1
    expect(course.active_ecosystem_preparation).to eq prep_1

    prep_2 = FactoryGirl.create :ecosystem_preparation, course: course
    expect(course.active_ecosystem_preparation).to eq prep_1

    FactoryGirl.create :ecosystem_update, ecosystem_preparation: prep_2
    expect(course.active_ecosystem_preparation).to eq prep_2
  end

  it 'can return its next ecosystem preparation' do
    expect(course.next_ecosystem_preparation).to be_nil

    prep_1 = FactoryGirl.create :ecosystem_preparation, course: course
    expect(course.next_ecosystem_preparation).to eq prep_1

    FactoryGirl.create :ecosystem_update, ecosystem_preparation: prep_1
    expect(course.next_ecosystem_preparation).to be_nil

    prep_2 = FactoryGirl.create :ecosystem_preparation, course: course
    expect(course.next_ecosystem_preparation).to eq prep_2

    FactoryGirl.create :ecosystem_update, ecosystem_preparation: prep_2
    expect(course.next_ecosystem_preparation).to be_nil
  end

  it 'can return its current ecosystem' do
    expect(course.current_ecosystem).to eq course.ecosystem

    prep_1 = FactoryGirl.create :ecosystem_preparation, course: course
    expect(course.current_ecosystem).to eq course.ecosystem

    FactoryGirl.create :ecosystem_update, ecosystem_preparation: prep_1
    expect(course.current_ecosystem).to eq prep_1.ecosystem

    prep_2 = FactoryGirl.create :ecosystem_preparation, course: course
    expect(course.current_ecosystem).to eq prep_1.ecosystem

    FactoryGirl.create :ecosystem_update, ecosystem_preparation: prep_2
    expect(course.current_ecosystem).to eq prep_2.ecosystem
  end

  it 'can return its next ecosystem' do
    expect(course.next_ecosystem).to be_nil

    prep_1 = FactoryGirl.create :ecosystem_preparation, course: course
    expect(course.next_ecosystem).to eq prep_1.ecosystem

    FactoryGirl.create :ecosystem_update, ecosystem_preparation: prep_1
    expect(course.next_ecosystem).to be_nil

    prep_2 = FactoryGirl.create :ecosystem_preparation, course: course
    expect(course.next_ecosystem).to eq prep_2.ecosystem

    FactoryGirl.create :ecosystem_update, ecosystem_preparation: prep_2
    expect(course.next_ecosystem).to be_nil
  end
end
