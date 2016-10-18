class CourseContainer < ActiveRecord::Base

  self.primary_key = 'container_uuid'

  belongs_to :course, foreign_key: 'uuid', primary_key: 'course_uuid'

  has_many :students, class_name: 'CourseStudent', inverse_of: 'container',
           primary_key: 'container_uuid', foreign_key: 'container_uuid'

end
