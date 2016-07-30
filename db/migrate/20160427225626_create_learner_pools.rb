class CreateLearnerPools < ActiveRecord::Migration
  def change
    create_table :learner_pools do |t|
      t.string     :uuid,  null: false,  limit: 36
      t.timestamps         null: false
    end

    add_index :learner_pools,  :uuid,
                               unique: true

    add_index :learner_pools,  :created_at
  end
end
