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

  has_many :course_rosters, primary_key: :uuid,
                            foreign_key: :course_uuid,
                            inverse_of: :course

  has_many :course_containers, primary_key: :uuid,
                               foreign_key: :course_uuid,
                               inverse_of: :course

  has_many :students, primary_key: :uuid,
                      foreign_key: :course_uuid,
                      inverse_of: :course

  has_many :course_exercise_exclusions, primary_key: :uuid,
                                        foreign_key: :course_uuid,
                                        inverse_of: :course

  has_many :course_active_dates, primary_key: :uuid,
                                 foreign_key: :course_uuid,
                                 inverse_of: :course

  validates :ecosystem_uuid, presence: true

  def active_ecosystem_preparation
    ecosystem_preparations.joins(:ecosystem_update).order(:sequence_number).last
  end

  def next_ecosystem_preparation
    # Search only preparations that have not been applied
    prep = ecosystem_preparations.joins{ecosystem_update.outer}
                                 .where(ecosystem_update: { id: nil })
                                 .order(:sequence_number).last

    # Return nil if next preparation is missing, obsolete or active
    prep if prep.present? && ( active_ecosystem_preparation.nil? ||
                               prep.sequence_number > active_ecosystem_preparation.sequence_number )
  end

  def current_ecosystem
    active_ecosystem_preparation&.ecosystem || ecosystem
  end

  def next_ecosystem
    next_ecosystem_preparation&.ecosystem
  end
end
