class Learner < ActiveRecord::Base
  has_and_belongs_to_many :learner_pools
end
