class CreateReceiverProtocols < ActiveRecord::Migration
  def change
    create_table :receiver_protocols do |t|
      t.uuid     :receiver_uuid,        null: false
      t.uuid     :instance_uuid,        null: false

      t.uuid     :boss_uuid,            null: false
      t.string   :boss_command,         null: false
      t.integer  :boss_instance_count,  null: false

      t.string   :instance_command,     null: false
      t.string   :instance_status,      null: false

      t.integer  :instance_modulo,      null: false

      t.timestamps                      null: false
    end

    add_index  :receiver_protocols,  :receiver_uuid

    add_index  :receiver_protocols,  :instance_uuid,
                                     unique: true

    add_index  :receiver_protocols,  [:receiver_uuid, :instance_modulo],
                                     unique: true
  end
end
