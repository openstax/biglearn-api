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

ActiveRecord::Schema.define(version: 20160829233953) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
  add_index "bundle_response_confirmations", ["bundle_uuid"], name: "index_bundle_response_confirmations_on_bundle_uuid", using: :btree
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

  create_table "exper_increasing_counters", force: :cascade do |t|
    t.uuid    "uuid",    null: false
    t.integer "counter", null: false
  end

  add_index "exper_increasing_counters", ["uuid", "counter"], name: "index_exper_increasing_counters_on_uuid_and_counter", unique: true, using: :btree

  create_table "protocol_records", force: :cascade do |t|
    t.string   "protocol_name",   null: false
    t.uuid     "group_uuid",      null: false
    t.uuid     "instance_uuid",   null: false
    t.integer  "instance_count",  null: false
    t.integer  "instance_modulo", null: false
    t.uuid     "boss_uuid",       null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "protocol_records", ["group_uuid", "instance_modulo"], name: "index_protocol_records_on_group_uuid_and_instance_modulo", unique: true, using: :btree
  add_index "protocol_records", ["group_uuid"], name: "index_protocol_records_on_group_uuid", using: :btree
  add_index "protocol_records", ["instance_uuid"], name: "index_protocol_records_on_instance_uuid", unique: true, using: :btree

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

  create_table "x_test1s", force: :cascade do |t|
    t.uuid     "uuid",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "x_test1s", ["created_at"], name: "index_x_test1s_on_created_at", using: :btree
  add_index "x_test1s", ["uuid"], name: "index_x_test1s_on_uuid", unique: true, using: :btree

end
