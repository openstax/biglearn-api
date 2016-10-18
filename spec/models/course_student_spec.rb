require 'rails_helper'

RSpec.describe CourseStudent, type: :model do
  it "and it's associations can be created" do

    c = FactoryGirl.create(:course)

    cc = c.containers.build(container_uuid: SecureRandom.uuid.to_s)

    cc.students.build(student_uuid: SecureRandom.uuid.to_s)

    expect(cc.save!).to be(true)

    expect(c.containers.length).to eq(1)
    expect(c.students.length).to eq(1)
  end
end
