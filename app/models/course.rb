class Course < ActiveRecord::Base
  include AppendOnly
  include HasUniqueUuid

  # Note: This is just the initial ecosystem for the course (before any updates)
  belongs_to :ecosystem, primary_key: :uuid,
                         foreign_key: :ecosystem_uuid

  has_many :ecosystem_preparations, primary_key: :uuid,
                                    foreign_key: :course_uuid,
                                    inverse_of: :course
  has_many :ecosystem_updates, through: :ecosystem_preparations

  validates :ecosystem, presence: true
end
