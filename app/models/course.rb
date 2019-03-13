class Course < ApplicationRecord
  include UniqueUuid
  include MetadataSequenceNumber

  has_many :course_events, primary_key: :uuid,
                           foreign_key: :course_uuid,
                           inverse_of: :course

  validates :initial_ecosystem_uuid, presence: true
  validates :sequence_number,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
