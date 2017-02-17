# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20170206191822) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assignment_pes", force: :cascade do |t|
    t.uuid     "uuid",            null: false
    t.uuid     "assignment_uuid", null: false
    t.uuid     "exercise_uuids",  null: false, array: true
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "assignment_pes", ["assignment_uuid"], name: "index_assignment_pes_on_assignment_uuid", unique: true, using: :btree
  add_index "assignment_pes", ["uuid"], name: "index_assignment_pes_on_uuid", unique: true, using: :btree

  create_table "assignment_spes", force: :cascade do |t|
    t.uuid     "uuid",            null: false
    t.uuid     "assignment_uuid", null: false
    t.uuid     "exercise_uuids",  null: false, array: true
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "assignment_spes", ["assignment_uuid"], name: "index_assignment_spes_on_assignment_uuid", unique: true, using: :btree
  add_index "assignment_spes", ["uuid"], name: "index_assignment_spes_on_uuid", unique: true, using: :btree

  create_table "assignments", force: :cascade do |t|
    t.uuid     "uuid",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "assignments", ["uuid"], name: "index_assignments_on_uuid", unique: true, using: :btree

  create_table "book_containers", force: :cascade do |t|
    t.uuid     "uuid",           null: false
    t.uuid     "ecosystem_uuid", null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "book_containers", ["ecosystem_uuid"], name: "index_book_containers_on_ecosystem_uuid", using: :btree
  add_index "book_containers", ["uuid"], name: "index_book_containers_on_uuid", unique: true, using: :btree

  create_table "course_containers", force: :cascade do |t|
    t.uuid     "uuid",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "course_containers", ["uuid"], name: "index_course_containers_on_uuid", unique: true, using: :btree

  create_table "course_events", force: :cascade do |t|
    t.uuid     "uuid",            null: false
    t.uuid     "course_uuid",     null: false
    t.integer  "sequence_number", null: false
    t.integer  "type",            null: false
    t.jsonb    "data",            null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "course_events", ["course_uuid", "type"], name: "index_course_events_on_course_uuid_and_type", using: :btree
  add_index "course_events", ["sequence_number", "course_uuid"], name: "index_course_events_on_sequence_number_and_course_uuid", unique: true, using: :btree
  add_index "course_events", ["uuid"], name: "index_course_events_on_uuid", unique: true, using: :btree

  create_table "ecosystem_events", force: :cascade do |t|
    t.uuid     "uuid",            null: false
    t.uuid     "ecosystem_uuid",  null: false
    t.integer  "sequence_number", null: false
    t.integer  "type",            null: false
    t.jsonb    "data",            null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "ecosystem_events", ["ecosystem_uuid", "type"], name: "index_ecosystem_events_on_ecosystem_uuid_and_type", using: :btree
  add_index "ecosystem_events", ["sequence_number", "ecosystem_uuid"], name: "index_ecosystem_events_on_sequence_number_and_ecosystem_uuid", unique: true, using: :btree
  add_index "ecosystem_events", ["uuid"], name: "index_ecosystem_events_on_uuid", unique: true, using: :btree

  create_table "ecosystem_preparation_readies", force: :cascade do |t|
    t.uuid     "uuid",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "ecosystem_preparation_readies", ["uuid"], name: "index_ecosystem_preparation_readies_on_uuid", unique: true, using: :btree

  create_table "student_clues", force: :cascade do |t|
    t.uuid     "uuid",                null: false
    t.uuid     "student_uuid",        null: false
    t.uuid     "book_container_uuid", null: false
    t.jsonb    "data",                null: false
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "student_clues", ["book_container_uuid"], name: "index_student_clues_on_book_container_uuid", using: :btree
  add_index "student_clues", ["student_uuid", "book_container_uuid"], name: "index_student_clues_on_student_uuid_and_book_container_uuid", unique: true, using: :btree
  add_index "student_clues", ["uuid"], name: "index_student_clues_on_uuid", unique: true, using: :btree

  create_table "student_pes", force: :cascade do |t|
    t.uuid     "uuid",           null: false
    t.uuid     "student_uuid",   null: false
    t.uuid     "exercise_uuids", null: false, array: true
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "student_pes", ["student_uuid"], name: "index_student_pes_on_student_uuid", unique: true, using: :btree
  add_index "student_pes", ["uuid"], name: "index_student_pes_on_uuid", unique: true, using: :btree

  create_table "students", force: :cascade do |t|
    t.uuid     "uuid",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "students", ["uuid"], name: "index_students_on_uuid", unique: true, using: :btree

  create_table "teacher_clues", force: :cascade do |t|
    t.uuid     "uuid",                  null: false
    t.uuid     "course_container_uuid", null: false
    t.uuid     "book_container_uuid",   null: false
    t.jsonb    "data",                  null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "teacher_clues", ["book_container_uuid"], name: "index_teacher_clues_on_book_container_uuid", using: :btree
  add_index "teacher_clues", ["course_container_uuid", "book_container_uuid"], name: "index_teacher_clues_on_course_cont_uuid_and_book_cont_uuid", unique: true, using: :btree
  add_index "teacher_clues", ["uuid"], name: "index_teacher_clues_on_uuid", unique: true, using: :btree

end
