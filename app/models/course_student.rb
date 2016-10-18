class CourseStudent < ActiveRecord::Base

  belongs_to :container, class_name: 'CourseContainer',
             foreign_key: 'container_uuid', primary_key: 'container_uuid'

  validates :student_uuid, presence: true
end
