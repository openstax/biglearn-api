class CreateLearnerBatchEntries < ActiveRecord::Migration
  def change
    create_table :learner_batch_entries do |t|
      t.string  :learner_batch_uuid,  null: false,  limit: 36
      t.string  :learner_uuid,        null: false,  limit: 36
    end

    add_index :learner_batch_entries,  [:learner_batch_uuid, :learner_uuid],
                                       unique: true,
                                       name: 'index_lbe_lb_uuid_l_uuid_unique'

    add_index :learner_batch_entries,  :learner_batch_uuid
  end
end
