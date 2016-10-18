class CourseContainer < ActiveRecord::Base

  self.primary_key = 'container_uuid'

  belongs_to :course, primary_key: 'uuid', foreign_key: 'course_uuid'

  has_many :students, class_name: 'CourseStudent', inverse_of: 'container',
           primary_key: 'container_uuid', foreign_key: 'container_uuid'

  validates :course, presence: true
end
