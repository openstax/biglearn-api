class Question < ActiveRecord::Base
  has_and_belongs_to_many :question_pools
end
