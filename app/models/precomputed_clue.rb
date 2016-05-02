class PrecomputedClue < ActiveRecord::Base
  belongs_to :learner_pool
  belongs_to :question_pool
  belongs_to :clue
end
