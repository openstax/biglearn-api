class EcosystemMap < ActiveRecord::Base
  include AppendOnly
  include HasUniqueUuid

  belongs_to :from_ecosystem, class_name: 'Ecosystem',
                              primary_key: :uuid,
                              foreign_key: :from_ecosystem_uuid

  belongs_to :to_ecosystem, class_name: 'Ecosystem',
                            primary_key: :uuid,
                            foreign_key: :to_ecosystem_uuid

  validates :from_ecosystem,    presence: true
  validates :to_ecosystem,      presence: true
  validates :to_ecosystem_uuid, uniqueness: { scope: :from_ecosystem_uuid }
end
