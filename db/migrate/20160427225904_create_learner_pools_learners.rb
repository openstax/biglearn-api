class CreateLearnerPoolsLearners < ActiveRecord::Migration
  def change
    create_table :learner_pools_learners, id: false do |t|
      t.belongs_to :learner,       null: false, index: true
      t.belongs_to :learner_pool,  null: false, index: true
    end
  end
end
