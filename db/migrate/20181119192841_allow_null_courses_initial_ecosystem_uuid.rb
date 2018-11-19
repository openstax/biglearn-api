class AllowNullCoursesInitialEcosystemUuid < ActiveRecord::Migration[5.0]
  def up
    change_column_null :courses, :initial_ecosystem_uuid, true
  end

  def down
    change_column_null :courses, :initial_ecosystem_uuid, false
  end
end
