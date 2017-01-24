class EcosystemPreparation < ActiveRecord::Base
  include AppendOnly
  include HasUniqueUuid

  has_one :ecosystem_update, primary_key: :uuid,
                             foreign_key: :preparation_uuid,
                             inverse_of: :ecosystem_preparation

  belongs_to :course, primary_key: :uuid,
                      foreign_key: :course_uuid,
                      inverse_of: :ecosystem_preparations

  belongs_to :ecosystem, primary_key: :uuid,
                         foreign_key: :ecosystem_uuid,
                         inverse_of: :ecosystem_preparations

  validates :course,    presence: true
  validates :ecosystem, presence: true
  validates :sequence_number, presence: true, uniqueness: { scope: :course_uuid }

  # TODO: Validate that there is a valid ecosystem map from the previous eco to this one?
end
