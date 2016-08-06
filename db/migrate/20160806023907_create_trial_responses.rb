class CreateTrialResponses < ActiveRecord::Migration
  def change
    create_table :trial_responses do |t|
      t.uuid    :response_uuid,  null: false
      t.uuid    :trial_uuid,     null: false
      t.uuid    :learner_uuid,   null: false
      t.uuid    :question_uuid,  null: false
      t.boolean :is_correct,     null: false

      t.timestamps
    end

    add_index :trial_responses,  :response_uuid,  unique: true
  end
end
