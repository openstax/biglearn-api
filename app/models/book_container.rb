class BookContainer < ApplicationRecord
  include AppendOnlyWithUniqueUuid

  belongs_to :ecosystem, primary_key: :uuid,
                         foreign_key: :ecosystem_uuid,
                         inverse_of: :book_containers

  has_many :student_clues, primary_key: :uuid,
                           foreign_key: :book_container_uuid,
                           inverse_of: :book_container
  has_many :teacher_clues, primary_key: :uuid,
                           foreign_key: :book_container_uuid,
                           inverse_of: :book_container

  validates :ecosystem_uuid, presence: true
end
