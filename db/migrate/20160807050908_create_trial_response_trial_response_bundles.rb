class CreateTrialResponseTrialResponseBundles < ActiveRecord::Migration
  def change
    create_table :trial_response_trial_response_bundles do |t|
      t.uuid  :trial_response_uuid,         null: false
      t.uuid  :trial_response_bundle_uuid,  null: false

      t.timestamps                          null: false
    end

    add_index  :trial_response_trial_response_bundles,  :trial_response_uuid,
                                                        unique: true,
                                                        name:   'index_trtrb_tr_uuid_unique'

    add_index  :trial_response_trial_response_bundles,  :trial_response_bundle_uuid,
                                                        name: 'index_trtrb_trb_uuid'
  end
end
