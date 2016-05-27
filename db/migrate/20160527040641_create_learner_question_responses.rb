class CreateLearnerQuestionResponses < ActiveRecord::Migration
  def change
    create_table :learner_question_responses do |t|
      t.string     :uuid,           null: false,  limit: 36
      t.string     :learner_uuid,   null: false,  limit: 36
      t.string     :question_uuid,  null: false,  limit: 36
      t.boolean    :correct,        null: false

      t.timestamps                  null: false
    end

    add_index :learner_question_responses,  :uuid,
                                            unique: true
  end
end
