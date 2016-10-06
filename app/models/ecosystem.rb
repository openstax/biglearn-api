class Ecosystem < ActiveRecord::Base
  has_one :course, :foreign_key => 'ecosystem_uuid', :primary_key => 'ecosystem_uuid'
end
