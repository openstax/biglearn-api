class ExperOneEvent < ActiveRecord::Base
  has_many :course_events, as: :event
end
