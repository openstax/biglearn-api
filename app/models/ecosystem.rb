class Ecosystem < ActiveRecord::Base
  include AppendOnly
  include HasUniqueUuid

  belongs_to :book, primary_key: :uuid,
                    foreign_key: :book_uuid,
                    inverse_of: :ecosystems

  has_many :book_containers, through: :book
  has_many :exercise_pools, through: :book_containers

  has_many :ecosystem_preparations, primary_key: :uuid,
                                    foreign_key: :ecosystem_uuid,
                                    inverse_of: :ecosystem
  has_many :ecosystem_updates, through: :ecosystem_preparations

  has_many :assignments, primary_key: :uuid,
                         foreign_key: :ecosystem_uuid,
                         inverse_of: :ecosystem

  validates :book, presence: true
end
