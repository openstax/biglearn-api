class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include UniqueUuid
  include PluckWithKeys
end
