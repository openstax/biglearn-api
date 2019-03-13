class NonNullCourseEcosystem < ActiveRecord::Migration[5.0]
  def change
    change_column_null :courses, :initial_ecosystem_uuid, false
  end
end
