class EcosystemUpdate < ActiveRecord::Base
  include AppendOnly
  include HasUniqueUuid

  belongs_to :ecosystem_preparation, primary_key: :uuid,
                                     foreign_key: :preparation_uuid,
                                     inverse_of: :ecosystem_update
  has_one :course, through: :ecosystem_preparation
  has_one :ecosystem, through: :ecosystem_preparation

  validates :ecosystem_preparation, presence: true
end
