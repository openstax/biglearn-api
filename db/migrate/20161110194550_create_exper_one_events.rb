class CreateExperOneEvents < ActiveRecord::Migration
  def change
    create_table :exper_one_events do |t|
      t.uuid        :uuid,   null: false
      t.integer     :data,   null: false

      t.timestamps           null: false
    end

    add_index :exper_one_events,  :uuid,
                                  unique: true

    add_index :exper_one_events,  :created_at
  end
end
