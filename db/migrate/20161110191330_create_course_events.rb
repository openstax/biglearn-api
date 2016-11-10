class CreateCourseEvents < ActiveRecord::Migration
  def change
    create_table :course_events do |t|
      t.uuid        :uuid,             null: false
      t.uuid        :course_uuid,      null: false
      t.string      :event_type,       null: false
      t.integer     :event_id,         null: false
      t.integer     :sequence_number,  null: false

      t.timestamps                     null: false
    end

    add_index :course_events,  :uuid,
                               unique: true

    add_index :course_events,  [:course_uuid, :sequence_number],
                               unique: true,
                               name:   'index_ce_on_c_uuid_sn_uniq'

    add_index :course_events,  [:course_uuid, :event_type, :event_id],
                               unique: true,
                               name:   'index_ce_on_c_uuid_et_eid_uniq'

    add_index :course_events,  :created_at
  end
end
