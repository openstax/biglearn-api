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

ActiveRecord::Schema.define(version: 20160817194653) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "response_bundle_confirmations", force: :cascade do |t|
    t.uuid     "response_bundle_uuid", null: false
    t.uuid     "receiver_uuid",        null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "response_bundle_confirmations", ["receiver_uuid"], name: "index_response_bundle_confirmations_on_receiver_uuid", using: :btree
  add_index "response_bundle_confirmations", ["response_bundle_uuid", "receiver_uuid"], name: "index_rbc_rb_uuid_r_uuid_unique", unique: true, using: :btree
  add_index "response_bundle_confirmations", ["response_bundle_uuid"], name: "index_response_bundle_confirmations_on_response_bundle_uuid", using: :btree

  create_table "response_bundle_entries", force: :cascade do |t|
    t.uuid     "response_bundle_uuid", null: false
    t.uuid     "response_uuid",        null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "response_bundle_entries", ["response_bundle_uuid", "response_uuid"], name: "index_rbe_rb_uuid_r_uuid_unique", unique: true, using: :btree
  add_index "response_bundle_entries", ["response_bundle_uuid"], name: "index_response_bundle_entries_on_response_bundle_uuid", using: :btree
  add_index "response_bundle_entries", ["response_uuid"], name: "index_response_bundle_entries_on_response_uuid", using: :btree

  create_table "response_bundle_receipts", force: :cascade do |t|
    t.uuid     "response_bundle_uuid", null: false
    t.uuid     "receiver_uuid",        null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "response_bundle_receipts", ["receiver_uuid"], name: "index_response_bundle_receipts_on_receiver_uuid", using: :btree
  add_index "response_bundle_receipts", ["response_bundle_uuid", "receiver_uuid"], name: "index_rbr_rb_uuid_r_uuid_unique", unique: true, using: :btree
  add_index "response_bundle_receipts", ["response_bundle_uuid"], name: "index_response_bundle_receipts_on_response_bundle_uuid", using: :btree

  create_table "response_bundles", force: :cascade do |t|
    t.uuid     "uuid",            null: false
    t.boolean  "is_open",         null: false
    t.integer  "partition_value", null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "response_bundles", ["is_open"], name: "index_response_bundles_on_is_open", using: :btree
  add_index "response_bundles", ["uuid"], name: "index_response_bundles_on_uuid", unique: true, using: :btree

  create_table "responses", force: :cascade do |t|
    t.uuid     "uuid",            null: false
    t.uuid     "trial_uuid",      null: false
    t.integer  "trial_sequence",  null: false
    t.uuid     "learner_uuid",    null: false
    t.uuid     "question_uuid",   null: false
    t.boolean  "is_correct",      null: false
    t.datetime "responded_at",    null: false
    t.integer  "partition_value", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "responses", ["trial_uuid", "trial_sequence"], name: "index_responses_on_trial_uuid_and_trial_sequence", unique: true, using: :btree
  add_index "responses", ["uuid"], name: "index_responses_on_uuid", unique: true, using: :btree

end
