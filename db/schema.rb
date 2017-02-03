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

ActiveRecord::Schema.define(version: 20170127213101) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "citext"

  create_table "assigned_exercises", force: :cascade do |t|
    t.uuid     "uuid",            null: false
    t.uuid     "assignment_uuid", null: false
    t.uuid     "trial_uuid",      null: false
    t.uuid     "exercise_uuid",   null: false
    t.boolean  "is_spe",          null: false
    t.boolean  "is_pe",           null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "assigned_exercises", ["assignment_uuid"], name: "index_assigned_exercises_on_assignment_uuid", using: :btree
  add_index "assigned_exercises", ["exercise_uuid", "assignment_uuid"], name: "index_assigned_exercises_on_exercise_uuid_and_assignment_uuid", unique: true, using: :btree
  add_index "assigned_exercises", ["trial_uuid", "assignment_uuid"], name: "index_assigned_exercises_on_trial_uuid_and_assignment_uuid", unique: true, using: :btree
  add_index "assigned_exercises", ["uuid"], name: "index_assigned_exercises_on_uuid", unique: true, using: :btree

  create_table "assignments", force: :cascade do |t|
    t.uuid     "uuid",                          null: false
    t.uuid     "assignment_uuid",               null: false
    t.integer  "sequence_number",               null: false
    t.boolean  "is_deleted",                    null: false
    t.uuid     "ecosystem_uuid",                null: false
    t.uuid     "student_uuid",                  null: false
    t.string   "assignment_type",               null: false
    t.datetime "opens_at"
    t.datetime "due_at"
    t.uuid     "assigned_book_container_uuids", null: false, array: true
    t.integer  "goal_num_tutor_assigned_spes",  null: false
    t.boolean  "spes_are_assigned",             null: false
    t.integer  "goal_num_tutor_assigned_pes",   null: false
    t.boolean  "pes_are_assigned",              null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "assignments", ["assignment_uuid", "sequence_number"], name: "index_assignments_on_assignment_uuid_and_sequence_number", unique: true, using: :btree
  add_index "assignments", ["ecosystem_uuid"], name: "index_assignments_on_ecosystem_uuid", using: :btree
  add_index "assignments", ["student_uuid"], name: "index_assignments_on_student_uuid", using: :btree
  add_index "assignments", ["uuid"], name: "index_assignments_on_uuid", unique: true, using: :btree

  create_table "book_containers", force: :cascade do |t|
    t.uuid     "uuid",         null: false
    t.uuid     "book_uuid",    null: false
    t.uuid     "parent_uuid"
    t.string   "cnx_identity"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "book_containers", ["book_uuid"], name: "index_book_containers_on_book_uuid", using: :btree
  add_index "book_containers", ["cnx_identity"], name: "index_book_containers_on_cnx_identity", using: :btree
  add_index "book_containers", ["parent_uuid"], name: "index_book_containers_on_parent_uuid", using: :btree
  add_index "book_containers", ["uuid"], name: "index_book_containers_on_uuid", unique: true, using: :btree

  create_table "books", force: :cascade do |t|
    t.uuid     "uuid",         null: false
    t.citext   "cnx_identity", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "books", ["cnx_identity"], name: "index_books_on_cnx_identity", unique: true, using: :btree
  add_index "books", ["uuid"], name: "index_books_on_uuid", unique: true, using: :btree

  create_table "bundle_response_bundles", force: :cascade do |t|
    t.uuid     "uuid",            null: false
    t.integer  "partition_value", null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "bundle_response_bundles", ["created_at"], name: "index_bundle_response_bundles_on_created_at", using: :btree
  add_index "bundle_response_bundles", ["partition_value"], name: "index_bundle_response_bundles_on_partition_value", using: :btree
  add_index "bundle_response_bundles", ["uuid"], name: "index_bundle_response_bundles_on_uuid", unique: true, using: :btree

  create_table "bundle_response_confirmations", force: :cascade do |t|
    t.uuid     "bundle_uuid",   null: false
    t.uuid     "receiver_uuid", null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "bundle_response_confirmations", ["bundle_uuid"], name: "index_brc_b_uuid_r_uuid_unique", unique: true, using: :btree
  add_index "bundle_response_confirmations", ["receiver_uuid"], name: "index_bundle_response_confirmations_on_receiver_uuid", using: :btree

  create_table "bundle_response_entries", force: :cascade do |t|
    t.uuid     "uuid",        null: false
    t.uuid     "bundle_uuid", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "bundle_response_entries", ["bundle_uuid"], name: "index_bre_b_uuid", using: :btree
  add_index "bundle_response_entries", ["uuid"], name: "index_bre_uuid_unique", unique: true, using: :btree

  create_table "bundle_responses", force: :cascade do |t|
    t.uuid     "uuid",            null: false
    t.integer  "partition_value", null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "bundle_responses", ["created_at"], name: "index_bundle_responses_on_created_at", using: :btree
  add_index "bundle_responses", ["partition_value"], name: "index_bundle_responses_on_partition_value", using: :btree
  add_index "bundle_responses", ["uuid"], name: "index_bundle_responses_on_uuid", unique: true, using: :btree

  create_table "bundle_x_test1_bundles", force: :cascade do |t|
    t.uuid     "uuid",            null: false
    t.integer  "partition_value", null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "bundle_x_test1_bundles", ["created_at"], name: "index_bundle_x_test1_bundles_on_created_at", using: :btree
  add_index "bundle_x_test1_bundles", ["uuid"], name: "index_bundle_x_test1_bundles_on_uuid", unique: true, using: :btree

  create_table "bundle_x_test1_confirmations", force: :cascade do |t|
    t.uuid     "bundle_uuid",   null: false
    t.uuid     "receiver_uuid", null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "bundle_x_test1_confirmations", ["bundle_uuid", "receiver_uuid"], name: "index_bxt1c_b_uuid_r_uuid_uniq", unique: true, using: :btree
  add_index "bundle_x_test1_confirmations", ["bundle_uuid"], name: "index_bundle_x_test1_confirmations_on_bundle_uuid", using: :btree
  add_index "bundle_x_test1_confirmations", ["receiver_uuid"], name: "index_bundle_x_test1_confirmations_on_receiver_uuid", using: :btree

  create_table "bundle_x_test1_entries", force: :cascade do |t|
    t.uuid     "uuid",        null: false
    t.uuid     "bundle_uuid", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "bundle_x_test1_entries", ["bundle_uuid"], name: "index_bundle_x_test1_entries_on_bundle_uuid", using: :btree
  add_index "bundle_x_test1_entries", ["uuid"], name: "index_bxt1e_uuid_uniq", unique: true, using: :btree

  create_table "bundle_x_test1s", force: :cascade do |t|
    t.uuid     "uuid",            null: false
    t.integer  "partition_value", null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "bundle_x_test1s", ["created_at"], name: "index_bundle_x_test1s_on_created_at", using: :btree
  add_index "bundle_x_test1s", ["partition_value"], name: "index_bundle_x_test1s_on_partition_value", using: :btree
  add_index "bundle_x_test1s", ["uuid"], name: "index_bundle_x_test1s_on_uuid", unique: true, using: :btree

  create_table "course_active_dates", force: :cascade do |t|
    t.uuid     "uuid",            null: false
    t.uuid     "course_uuid",     null: false
    t.integer  "sequence_number", null: false
    t.datetime "starts_at",       null: false
    t.datetime "ends_at",         null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "course_active_dates", ["course_uuid", "sequence_number"], name: "index_course_active_dates_on_course_uuid_and_sequence_number", unique: true, using: :btree
  add_index "course_active_dates", ["uuid"], name: "index_course_active_dates_on_uuid", unique: true, using: :btree

  create_table "course_containers", force: :cascade do |t|
    t.uuid     "uuid",        null: false
    t.uuid     "course_uuid", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "course_containers", ["course_uuid"], name: "index_course_containers_on_course_uuid", using: :btree
  add_index "course_containers", ["uuid"], name: "index_course_containers_on_uuid", unique: true, using: :btree

  create_table "course_exercise_exclusions", force: :cascade do |t|
    t.uuid     "uuid",                          null: false
    t.uuid     "course_uuid",                   null: false
    t.integer  "sequence_number",               null: false
    t.uuid     "excluded_exercise_uuids",       null: false, array: true
    t.uuid     "excluded_exercise_group_uuids", null: false, array: true
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "course_exercise_exclusions", ["course_uuid", "sequence_number"], name: "index_course_exercise_exclusions_on_c_uuid_and_s_number_uniq", unique: true, using: :btree
  add_index "course_exercise_exclusions", ["uuid"], name: "index_course_exercise_exclusions_on_uuid", unique: true, using: :btree

  create_table "course_rosters", force: :cascade do |t|
    t.uuid     "uuid",            null: false
    t.uuid     "course_uuid",     null: false
    t.integer  "sequence_number", null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "course_rosters", ["course_uuid", "sequence_number"], name: "index_course_rosters_on_course_uuid_and_sequence_number", unique: true, using: :btree
  add_index "course_rosters", ["uuid"], name: "index_course_rosters_on_uuid", unique: true, using: :btree

  create_table "courses", force: :cascade do |t|
    t.uuid     "uuid",           null: false
    t.uuid     "ecosystem_uuid", null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "courses", ["ecosystem_uuid"], name: "index_courses_on_ecosystem_uuid", using: :btree
  add_index "courses", ["uuid"], name: "index_courses_on_uuid", unique: true, using: :btree

  create_table "ecosystem_maps", force: :cascade do |t|
    t.uuid     "uuid",                    null: false
    t.uuid     "from_ecosystem_uuid",     null: false
    t.uuid     "to_ecosystem_uuid",       null: false
    t.jsonb    "cnx_pagemodule_mappings", null: false, array: true
    t.jsonb    "exercise_mappings",       null: false, array: true
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "ecosystem_maps", ["from_ecosystem_uuid", "to_ecosystem_uuid"], name: "index_e_maps_from_e_uuid_to_e_uuid_uniq", unique: true, using: :btree
  add_index "ecosystem_maps", ["to_ecosystem_uuid"], name: "index_ecosystem_maps_on_to_ecosystem_uuid", using: :btree
  add_index "ecosystem_maps", ["uuid"], name: "index_ecosystem_maps_on_uuid", unique: true, using: :btree

  create_table "ecosystem_preparations", force: :cascade do |t|
    t.uuid     "uuid",            null: false
    t.uuid     "course_uuid",     null: false
    t.uuid     "ecosystem_uuid",  null: false
    t.integer  "sequence_number", null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "ecosystem_preparations", ["course_uuid", "sequence_number"], name: "index_ecosystem_preparations_on_course_uuid_and_sequence_number", unique: true, using: :btree
  add_index "ecosystem_preparations", ["ecosystem_uuid"], name: "index_ecosystem_preparations_on_ecosystem_uuid", using: :btree
  add_index "ecosystem_preparations", ["uuid"], name: "index_ecosystem_preparations_on_uuid", unique: true, using: :btree

  create_table "ecosystem_updates", force: :cascade do |t|
    t.uuid     "uuid",             null: false
    t.uuid     "preparation_uuid", null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "ecosystem_updates", ["preparation_uuid"], name: "index_ecosystem_updates_on_preparation_uuid", unique: true, using: :btree
  add_index "ecosystem_updates", ["uuid"], name: "index_ecosystem_updates_on_uuid", unique: true, using: :btree

  create_table "ecosystems", force: :cascade do |t|
    t.uuid     "uuid",       null: false
    t.uuid     "book_uuid",  null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "ecosystems", ["book_uuid"], name: "index_ecosystems_on_book_uuid", using: :btree
  add_index "ecosystems", ["uuid"], name: "index_ecosystems_on_uuid", unique: true, using: :btree

  create_table "exercise_pools", force: :cascade do |t|
    t.uuid     "uuid",                                      null: false
    t.uuid     "container_uuid",                            null: false
    t.boolean  "use_for_clue",                              null: false
    t.string   "use_for_personalized_for_assignment_types", null: false, array: true
    t.uuid     "exercise_uuids",                            null: false, array: true
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "exercise_pools", ["container_uuid"], name: "index_exercise_pools_on_container_uuid", using: :btree
  add_index "exercise_pools", ["uuid"], name: "index_exercise_pools_on_uuid", unique: true, using: :btree

  create_table "exercises", force: :cascade do |t|
    t.uuid     "uuid",              null: false
    t.uuid     "exercises_uuid",    null: false
    t.integer  "exercises_version", null: false
    t.string   "los",               null: false, array: true
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "exercises", ["exercises_uuid", "exercises_version"], name: "index_exercises_on_exercises_uuid_and_exercises_version", unique: true, using: :btree
  add_index "exercises", ["uuid"], name: "index_exercises_on_uuid", unique: true, using: :btree

  create_table "global_exercise_exclusions", force: :cascade do |t|
    t.uuid     "uuid",                          null: false
    t.integer  "sequence_number",               null: false
    t.uuid     "excluded_exercise_uuids",       null: false, array: true
    t.uuid     "excluded_exercise_group_uuids", null: false, array: true
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "global_exercise_exclusions", ["sequence_number"], name: "index_global_exercise_exclusions_on_sequence_number", unique: true, using: :btree
  add_index "global_exercise_exclusions", ["uuid"], name: "index_global_exercise_exclusions_on_uuid", unique: true, using: :btree

  create_table "responses", force: :cascade do |t|
    t.uuid     "uuid",           null: false
    t.uuid     "trial_uuid",     null: false
    t.integer  "trial_sequence", null: false
    t.uuid     "learner_uuid",   null: false
    t.uuid     "question_uuid",  null: false
    t.boolean  "is_correct",     null: false
    t.datetime "responded_at",   null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "responses", ["created_at"], name: "index_responses_on_created_at", using: :btree
  add_index "responses", ["trial_uuid", "trial_sequence"], name: "index_responses_on_trial_uuid_and_trial_sequence", unique: true, using: :btree
  add_index "responses", ["uuid"], name: "index_responses_on_uuid", unique: true, using: :btree

  create_table "roster_containers", force: :cascade do |t|
    t.uuid     "uuid",                         null: false
    t.uuid     "roster_uuid",                  null: false
    t.uuid     "container_uuid",               null: false
    t.uuid     "parent_roster_container_uuid"
    t.boolean  "is_archived",                  null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "roster_containers", ["container_uuid"], name: "index_roster_containers_on_container_uuid", using: :btree
  add_index "roster_containers", ["parent_roster_container_uuid"], name: "index_roster_containers_on_parent_roster_container_uuid", using: :btree
  add_index "roster_containers", ["roster_uuid", "container_uuid"], name: "index_roster_containers_on_roster_uuid_and_container_uuid", unique: true, using: :btree
  add_index "roster_containers", ["uuid"], name: "index_roster_containers_on_uuid", unique: true, using: :btree

  create_table "roster_students", force: :cascade do |t|
    t.uuid     "uuid",                  null: false
    t.uuid     "roster_uuid",           null: false
    t.uuid     "roster_container_uuid", null: false
    t.uuid     "student_uuid",          null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "roster_students", ["roster_container_uuid"], name: "index_roster_students_on_roster_container_uuid", using: :btree
  add_index "roster_students", ["roster_uuid", "student_uuid"], name: "index_roster_students_on_roster_uuid_and_student_uuid", unique: true, using: :btree
  add_index "roster_students", ["student_uuid"], name: "index_roster_students_on_student_uuid", using: :btree
  add_index "roster_students", ["uuid"], name: "index_roster_students_on_uuid", unique: true, using: :btree

  create_table "students", force: :cascade do |t|
    t.uuid     "uuid",        null: false
    t.uuid     "course_uuid", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "students", ["course_uuid"], name: "index_students_on_course_uuid", using: :btree
  add_index "students", ["uuid"], name: "index_students_on_uuid", unique: true, using: :btree

  create_table "x_test1s", force: :cascade do |t|
    t.uuid     "uuid",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "x_test1s", ["created_at"], name: "index_x_test1s_on_created_at", using: :btree
  add_index "x_test1s", ["uuid"], name: "index_x_test1s_on_uuid", unique: true, using: :btree

end
