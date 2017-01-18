class Book < ActiveRecord::Base
  include AppendOnly
  include HasUniqueUuid

  has_many :ecosystems, primary_key: :uuid,
                        foreign_key: :book_uuid,
                        inverse_of: :book

  has_many :book_containers, primary_key: :uuid,
                             foreign_key: :book_uuid,
                             inverse_of: :book

  has_many :exercise_pools, through: :book_containers
end
