class CreateQuestionPoolEntries < ActiveRecord::Migration
  def change
    create_table :question_pool_entries, id: false do |t|
      t.string :question_uuid,       null: false,  limit: 36
      t.string :question_pool_uuid,  null: false,  limit: 36
    end

    add_index :question_pool_entries,  [:question_pool_uuid, :question_uuid],
                                        unique: true,
                                        name: 'index_qpe_qp_uuid_q_uuid_unique'

    add_index :question_pool_entries,  :question_pool_uuid
  end
end
