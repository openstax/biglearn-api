# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_09_30_214433) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "plpgsql"

  execute "SET check_function_bodies = off"

  create_function :next_ecosystem_metadata_sequence_number, sql_definition: <<-SQL
      CREATE OR REPLACE FUNCTION public.next_ecosystem_metadata_sequence_number()
       RETURNS integer
       LANGUAGE sql
      AS $function$
          SELECT PG_ADVISORY_XACT_LOCK(5676211225851683);
          SELECT COALESCE(MAX("ecosystems"."metadata_sequence_number"), -1) + 1 FROM "ecosystems"
        $function$
  SQL

  create_function :next_course_metadata_sequence_number, sql_definition: <<-SQL
      CREATE OR REPLACE FUNCTION public.next_course_metadata_sequence_number()
       RETURNS integer
       LANGUAGE sql
      AS $function$
          SELECT PG_ADVISORY_XACT_LOCK(49102217655775016);
          SELECT COALESCE(MAX("courses"."metadata_sequence_number"), -1) + 1 FROM "courses"
        $function$
  SQL

  execute "SET check_function_bodies = on"

  create_table "assignment_pes", id: :serial, force: :cascade do |t|
    t.uuid "uuid", null: false
    t.uuid "assignment_uuid", null: false
    t.citext "algorithm_name", null: false
    t.uuid "exercise_uuids", null: false, array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "spy_info", null: false
    t.uuid "calculation_uuid", null: false
    t.uuid "ecosystem_matrix_uuid", null: false
    t.index ["assignment_uuid", "algorithm_name"], name: "index_assignment_pes_on_assignment_uuid_and_algorithm_name", unique: true
    t.index ["calculation_uuid"], name: "index_assignment_pes_on_calculation_uuid"
    t.index ["ecosystem_matrix_uuid"], name: "index_assignment_pes_on_ecosystem_matrix_uuid"
    t.index ["uuid"], name: "index_assignment_pes_on_uuid", unique: true
  end

  create_table "assignment_spes", id: :serial, force: :cascade do |t|
    t.uuid "uuid", null: false
    t.uuid "assignment_uuid", null: false
    t.citext "algorithm_name", null: false
    t.uuid "exercise_uuids", null: false, array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "spy_info", null: false
    t.uuid "calculation_uuid", null: false
    t.uuid "ecosystem_matrix_uuid", null: false
    t.index ["assignment_uuid", "algorithm_name"], name: "index_assignment_spes_on_assignment_uuid_and_algorithm_name", unique: true
    t.index ["calculation_uuid"], name: "index_assignment_spes_on_calculation_uuid"
    t.index ["ecosystem_matrix_uuid"], name: "index_assignment_spes_on_ecosystem_matrix_uuid"
    t.index ["uuid"], name: "index_assignment_spes_on_uuid", unique: true
  end

  create_table "assignments", id: :serial, force: :cascade do |t|
    t.uuid "uuid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uuid"], name: "index_assignments_on_uuid", unique: true
  end

  create_table "book_containers", id: :serial, force: :cascade do |t|
    t.uuid "uuid", null: false
    t.uuid "ecosystem_uuid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ecosystem_uuid"], name: "index_book_containers_on_ecosystem_uuid"
    t.index ["uuid"], name: "index_book_containers_on_uuid", unique: true
  end

  create_table "course_containers", id: :serial, force: :cascade do |t|
    t.uuid "uuid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uuid"], name: "index_course_containers_on_uuid", unique: true
  end

  create_table "course_events", id: :serial, force: :cascade do |t|
    t.uuid "uuid", null: false
    t.uuid "course_uuid", null: false
    t.integer "sequence_number", null: false
    t.integer "type", null: false
    t.jsonb "data", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_uuid", "sequence_number"], name: "index_course_events_on_course_uuid_and_sequence_number", unique: true
    t.index ["type", "course_uuid", "sequence_number"], name: "index_course_events_on_type_and_c_uuid_and_sequence_number", unique: true
    t.index ["uuid"], name: "index_course_events_on_uuid", unique: true
  end

  create_table "courses", id: :serial, force: :cascade do |t|
    t.uuid "uuid", null: false
    t.integer "metadata_sequence_number", default: -> { "next_course_metadata_sequence_number()" }, null: false
    t.integer "sequence_number", null: false
    t.uuid "initial_ecosystem_uuid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["metadata_sequence_number"], name: "index_courses_on_metadata_sequence_number", unique: true
    t.index ["sequence_number"], name: "index_courses_on_sequence_number"
    t.index ["uuid"], name: "index_courses_on_uuid", unique: true
  end

  create_table "ecosystem_events", id: :serial, force: :cascade do |t|
    t.uuid "uuid", null: false
    t.uuid "ecosystem_uuid", null: false
    t.integer "sequence_number", null: false
    t.integer "type", null: false
    t.jsonb "data", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ecosystem_uuid", "sequence_number"], name: "index_ecosystem_events_on_ecosystem_uuid_and_sequence_number", unique: true
    t.index ["type", "ecosystem_uuid", "sequence_number"], name: "index_ecosystem_events_on_type_and_e_uuid_and_sequence_number", unique: true
    t.index ["uuid"], name: "index_ecosystem_events_on_uuid", unique: true
  end

  create_table "ecosystem_preparation_readies", id: :serial, force: :cascade do |t|
    t.uuid "uuid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uuid"], name: "index_ecosystem_preparation_readies_on_uuid", unique: true
  end

  create_table "ecosystems", id: :serial, force: :cascade do |t|
    t.uuid "uuid", null: false
    t.integer "metadata_sequence_number", default: -> { "next_ecosystem_metadata_sequence_number()" }, null: false
    t.integer "sequence_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["metadata_sequence_number"], name: "index_ecosystems_on_metadata_sequence_number", unique: true
    t.index ["sequence_number"], name: "index_ecosystems_on_sequence_number"
    t.index ["uuid"], name: "index_ecosystems_on_uuid", unique: true
  end

  create_table "student_clues", id: :serial, force: :cascade do |t|
    t.uuid "uuid", null: false
    t.uuid "student_uuid", null: false
    t.uuid "book_container_uuid", null: false
    t.citext "algorithm_name", null: false
    t.jsonb "data", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "calculation_uuid", null: false
    t.index ["book_container_uuid"], name: "index_student_clues_on_book_container_uuid"
    t.index ["calculation_uuid"], name: "index_student_clues_on_calculation_uuid"
    t.index ["student_uuid", "book_container_uuid", "algorithm_name"], name: "index_student_clues_on_student_uuid_and_book_container_uuid", unique: true
    t.index ["uuid"], name: "index_student_clues_on_uuid", unique: true
  end

  create_table "student_pes", id: :serial, force: :cascade do |t|
    t.uuid "uuid", null: false
    t.uuid "student_uuid", null: false
    t.citext "algorithm_name", null: false
    t.uuid "exercise_uuids", null: false, array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "spy_info", null: false
    t.uuid "calculation_uuid", null: false
    t.uuid "ecosystem_matrix_uuid", null: false
    t.index ["calculation_uuid"], name: "index_student_pes_on_calculation_uuid"
    t.index ["ecosystem_matrix_uuid"], name: "index_student_pes_on_ecosystem_matrix_uuid"
    t.index ["student_uuid", "algorithm_name"], name: "index_student_pes_on_student_uuid_and_algorithm_name", unique: true
    t.index ["uuid"], name: "index_student_pes_on_uuid", unique: true
  end

  create_table "students", id: :serial, force: :cascade do |t|
    t.uuid "uuid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uuid"], name: "index_students_on_uuid", unique: true
  end

  create_table "teacher_clues", id: :serial, force: :cascade do |t|
    t.uuid "uuid", null: false
    t.uuid "course_container_uuid", null: false
    t.uuid "book_container_uuid", null: false
    t.citext "algorithm_name", null: false
    t.jsonb "data", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "calculation_uuid", null: false
    t.index ["book_container_uuid"], name: "index_teacher_clues_on_book_container_uuid"
    t.index ["calculation_uuid"], name: "index_teacher_clues_on_calculation_uuid"
    t.index ["course_container_uuid", "book_container_uuid", "algorithm_name"], name: "index_teacher_clues_on_course_cont_uuid_and_book_cont_uuid", unique: true
    t.index ["uuid"], name: "index_teacher_clues_on_uuid", unique: true
  end

end
