class CreateLearnerBatches < ActiveRecord::Migration
  def change
    create_table :learner_batches do |t|
      t.string      :uuid,         null: false,  limit: 36
      t.integer     :num_entries,  null: false
      t.timestamps                 null: false
    end

    add_index :learner_batches,  :uuid,
                                 unique: true
  end
end
