class CreateTrialResponseBundles < ActiveRecord::Migration
  def change
    create_table :trial_response_bundles do |t|
      t.uuid        :uuid,     null: false
      t.boolean     :is_open,  null: false

      t.timestamps             null: false
    end

    add_index  :trial_response_bundles,  :uuid,
                                         unique: true

    add_index  :trial_response_bundles,  :is_open
  end
end
