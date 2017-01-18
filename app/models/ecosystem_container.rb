class EcosystemContainer < ActiveRecord::Base
  include AppendOnly
  include HasUniqueUuid

  belongs_to :ecosystem, primary_key: :uuid,
                         foreign_key: :ecosystem_uuid,
                         inverse_of: :ecosystem_containers

  belongs_to :parent_ecosystem_container, class_name: name,
                                          primary_key: :uuid,
                                          foreign_key: :parent_uuid,
                                          inverse_of: :child_ecosystem_containers
  has_many :child_ecosystem_containers, class_name: name,
                                        primary_key: :uuid,
                                        foreign_key: :parent_uuid,
                                        inverse_of: :parent_ecosystem_container

  has_many :ecosystem_pools, primary_key: :uuid,
                             foreign_key: :container_uuid,
                             inverse_of: :ecosystem_container

  validates :ecosystem, presence: true
end
