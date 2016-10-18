class Course < ActiveRecord::Base
  belongs_to :ecosystem, :foreign_key => 'ecosystem_uuid', :primary_key => 'ecosystem_uuid'

  has_many :containers, class_name: 'CourseContainer', inverse_of: :course,
           foreign_key: 'course_uuid', primary_key: 'uuid'

  has_many :students, through: :containers

end
