class AddSpyInfoFields < ActiveRecord::Migration[5.0]
  def change
    add_column :assignment_spes, :spy_info, :jsonb
    add_column :assignment_pes,  :spy_info, :jsonb
    add_column :student_pes,     :spy_info, :jsonb

    change_column_null :assignment_spes, :spy_info, false, {}
    change_column_null :assignment_pes,  :spy_info, false, {}
    change_column_null :student_pes,     :spy_info, false, {}
  end
end
