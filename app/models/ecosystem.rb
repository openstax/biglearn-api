class Ecosystem < ActiveRecord::Base
  include AppendOnly
  include HasUniqueUuid

  has_many :ecosystem_containers, primary_key: :uuid,
                                  foreign_key: :ecosystem_uuid,
                                  inverse_of: :ecosystem
  has_many :ecosystem_pools, through: :ecosystem_containers

  belongs_to :ecosystem_preparations, primary_key: :uuid,
                                      foreign_key: :ecosystem_uuid,
                                      inverse_of: :ecosystem
  has_many :ecosystem_updates, through: :ecosystem_preparations
end
