class Course < ActiveRecord::Base
  belongs_to :ecosystem, :foreign_key => 'ecosystem_uuid', :primary_key => 'ecosystem_uuid'
end
