class CreateExperIncreasingCounters < ActiveRecord::Migration
  def change
    create_table :exper_increasing_counters do |t|
      t.uuid        :uuid,         null: false
      t.integer     :counter,      null: false

      # t.timestamps                 null: false
    end

    add_index :exper_increasing_counters,  [:uuid, :counter],
                                           unique: true
  end
end
