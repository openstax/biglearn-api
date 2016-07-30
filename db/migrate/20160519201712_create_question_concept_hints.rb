class CreateQuestionConceptHints < ActiveRecord::Migration
  def change
    create_table :question_concept_hints do |t|
      t.string     :uuid,           null: false,  limit: 36
      t.string     :question_uuid,  null: false,  limit: 36
      t.string     :concept_uuid,   null: false,  limit: 36
      t.timestamps                  null: false
    end

    add_index :question_concept_hints,  :uuid,
                                        unique: true

    add_index :question_concept_hints,  [:question_uuid, :concept_uuid],
                                        unique: true,
                                        name: 'qch_q_uuid_c_uuid_unique'

    add_index :question_concept_hints,  :created_at
  end
end
