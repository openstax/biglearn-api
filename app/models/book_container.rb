class BookContainer < ActiveRecord::Base
  include AppendOnly
  include HasUniqueUuid

  belongs_to :book, primary_key: :uuid,
                    foreign_key: :book_uuid,
                    inverse_of: :book_containers

  belongs_to :parent_book_container, class_name: name,
                                     primary_key: :uuid,
                                     foreign_key: :parent_uuid,
                                     inverse_of: :child_book_containers
  has_many :child_book_containers, class_name: name,
                                   primary_key: :uuid,
                                   foreign_key: :parent_uuid,
                                   inverse_of: :parent_book_container

  has_many :exercise_pools, primary_key: :uuid,
                            foreign_key: :container_uuid,
                            inverse_of: :book_container

  validates :book, presence: true
end
