class CreateLearnerPoolEntries < ActiveRecord::Migration
  def change
    create_table :learner_pool_entries, id: false do |t|
      t.string :learner_uuid,       null: false,  limit: 36
      t.string :learner_pool_uuid,  null: false,  limit: 36
    end

    add_index :learner_pool_entries,  [:learner_pool_uuid, :learner_uuid],
                                       unique: true,
                                       name: 'index_lpe_lp_uuid_l_uuid_unique'

    add_index :learner_pool_entries,  :learner_pool_uuid
  end
end
