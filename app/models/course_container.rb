class CourseContainer < ActiveRecord::Base

  self.primary_key = 'container_uuid'

  belongs_to :course, primary_key: 'uuid', foreign_key: 'course_uuid'

  has_many :students, class_name: 'CourseStudent', inverse_of: 'container',
           primary_key: 'container_uuid', foreign_key: 'container_uuid'

  validates :course, presence: true

  before_destroy :ensure_no_students

  private

  def ensure_no_students
    if students.any?
      errors.add(:students, 'Cannot delete while students are present')
      return false # will need to be "throw(:abort)" in Rails 5
    end
  end

end
