require 'rails_helper'
require_relative 'shared_examples_for_append_only_with_unique_uuid'

RSpec.describe NotifyingAppendOnlyWithUniqueUuid, type: :concern, truncation: true do
  include_examples 'append_only_with_unique_uuid'

  it 'notifies the proper channel with the proper payload when appending' do
    CourseEvent.connection.execute 'LISTEN "course_events"'

    event_1_attributes = FactoryGirl.build(:course_event).attributes
    event_2_attributes = FactoryGirl.build(:course_event).attributes
    attributes_array = [ event_1_attributes, event_2_attributes ]
    CourseEvent.append attributes_array

    notified = false
    CourseEvent.connection.raw_connection.wait_for_notify(1) do |event, pid, payload|
      notified = true
      expect(event).to eq 'course_events'
      expect(pid).not_to eq Process.pid
      expect(payload.split(',')).to match_array attributes_array.map { |hash| hash['course_uuid'] }
    end
    expect(notified).to eq true
  end
end
