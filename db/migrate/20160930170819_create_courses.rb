class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.uuid          :uuid,              null: false
      t.uuid          :ecosystem_uuid,    null: false

      t.timestamps                        null: false
    end
    add_index         :courses, :uuid,
                                unique: true


  end
end
