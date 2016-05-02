class CreateLearnerPoolsLearners < ActiveRecord::Migration
  def change
    create_table :learner_pools_learners, id: false do |t|
      t.references :learner,       null: false,  foreign_key: true
      t.references :learner_pool,  null: false,  foreign_key: true

      t.index :learner_id
      t.index :learner_pool_id
    end
  end
end
