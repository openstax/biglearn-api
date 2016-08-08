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

ActiveRecord::Schema.define(version: 20160808014609) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "clues", force: :cascade do |t|
    t.string   "uuid",                 limit: 36, null: false
    t.float    "aggregate",                       null: false
    t.float    "left",                            null: false
    t.float    "right",                           null: false
    t.integer  "sample_size",                     null: false
    t.integer  "unique_learner_count",            null: false
    t.integer  "confidence",                      null: false
    t.integer  "level",                           null: false
    t.integer  "threshold",                       null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "clues", ["created_at"], name: "index_clues_on_created_at", using: :btree
  add_index "clues", ["uuid"], name: "index_clues_on_uuid", unique: true, using: :btree

  create_table "concepts", force: :cascade do |t|
    t.string   "uuid",       limit: 36, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "concepts", ["created_at"], name: "index_concepts_on_created_at", using: :btree
  add_index "concepts", ["uuid"], name: "index_concepts_on_uuid", unique: true, using: :btree

  create_table "learner_batch_entries", force: :cascade do |t|
    t.string "learner_batch_uuid", limit: 36, null: false
    t.string "learner_uuid",       limit: 36, null: false
  end

  add_index "learner_batch_entries", ["learner_batch_uuid", "learner_uuid"], name: "index_lbe_lb_uuid_l_uuid_unique", unique: true, using: :btree
  add_index "learner_batch_entries", ["learner_batch_uuid"], name: "index_learner_batch_entries_on_learner_batch_uuid", using: :btree

  create_table "learner_batches", force: :cascade do |t|
    t.string   "uuid",        limit: 36, null: false
    t.integer  "num_entries",            null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "learner_batches", ["uuid"], name: "index_learner_batches_on_uuid", unique: true, using: :btree

  create_table "learner_pool_entries", id: false, force: :cascade do |t|
    t.string "learner_uuid",      limit: 36, null: false
    t.string "learner_pool_uuid", limit: 36, null: false
  end

  add_index "learner_pool_entries", ["learner_pool_uuid", "learner_uuid"], name: "index_lpe_lp_uuid_l_uuid_unique", unique: true, using: :btree
  add_index "learner_pool_entries", ["learner_pool_uuid"], name: "index_learner_pool_entries_on_learner_pool_uuid", using: :btree

  create_table "learner_pools", force: :cascade do |t|
    t.string   "uuid",       limit: 36, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "learner_pools", ["created_at"], name: "index_learner_pools_on_created_at", using: :btree
  add_index "learner_pools", ["uuid"], name: "index_learner_pools_on_uuid", unique: true, using: :btree

  create_table "learner_question_responses", force: :cascade do |t|
    t.string   "uuid",          limit: 36, null: false
    t.string   "learner_uuid",  limit: 36, null: false
    t.string   "question_uuid", limit: 36, null: false
    t.boolean  "correct",                  null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "learner_question_responses", ["uuid"], name: "index_learner_question_responses_on_uuid", unique: true, using: :btree

  create_table "learners", force: :cascade do |t|
    t.string   "uuid",       limit: 36, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "learners", ["created_at"], name: "index_learners_on_created_at", using: :btree
  add_index "learners", ["uuid"], name: "index_learners_on_uuid", unique: true, using: :btree

  create_table "precomputed_clues", force: :cascade do |t|
    t.string   "uuid",               limit: 36, null: false
    t.string   "learner_pool_uuid",  limit: 36, null: false
    t.string   "question_pool_uuid", limit: 36, null: false
    t.string   "clue_uuid",          limit: 36, null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "precomputed_clues", ["clue_uuid"], name: "index_precomputed_clues_on_clue_uuid", unique: true, using: :btree
  add_index "precomputed_clues", ["created_at"], name: "index_precomputed_clues_on_created_at", using: :btree
  add_index "precomputed_clues", ["learner_pool_uuid"], name: "index_precomputed_clues_on_learner_pool_uuid", using: :btree
  add_index "precomputed_clues", ["question_pool_uuid"], name: "index_precomputed_clues_on_question_pool_uuid", using: :btree
  add_index "precomputed_clues", ["uuid"], name: "index_precomputed_clues_on_uuid", unique: true, using: :btree

  create_table "question_concept_hints", force: :cascade do |t|
    t.string   "uuid",          limit: 36, null: false
    t.string   "question_uuid", limit: 36, null: false
    t.string   "concept_uuid",  limit: 36, null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "question_concept_hints", ["created_at"], name: "index_question_concept_hints_on_created_at", using: :btree
  add_index "question_concept_hints", ["question_uuid", "concept_uuid"], name: "qch_q_uuid_c_uuid_unique", unique: true, using: :btree
  add_index "question_concept_hints", ["uuid"], name: "index_question_concept_hints_on_uuid", unique: true, using: :btree

  create_table "question_pool_entries", id: false, force: :cascade do |t|
    t.string "question_uuid",      limit: 36, null: false
    t.string "question_pool_uuid", limit: 36, null: false
  end

  add_index "question_pool_entries", ["question_pool_uuid", "question_uuid"], name: "index_qpe_qp_uuid_q_uuid_unique", unique: true, using: :btree
  add_index "question_pool_entries", ["question_pool_uuid"], name: "index_question_pool_entries_on_question_pool_uuid", using: :btree

  create_table "question_pools", force: :cascade do |t|
    t.string   "uuid",       limit: 36, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "question_pools", ["created_at"], name: "index_question_pools_on_created_at", using: :btree
  add_index "question_pools", ["uuid"], name: "index_question_pools_on_uuid", unique: true, using: :btree

  create_table "questions", force: :cascade do |t|
    t.string   "uuid",       limit: 36, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "questions", ["created_at"], name: "index_questions_on_created_at", using: :btree
  add_index "questions", ["uuid"], name: "index_questions_on_uuid", unique: true, using: :btree

  create_table "receiver_protocols", force: :cascade do |t|
    t.uuid     "receiver_uuid",       null: false
    t.uuid     "instance_uuid",       null: false
    t.uuid     "boss_uuid",           null: false
    t.string   "boss_command",        null: false
    t.integer  "boss_instance_count", null: false
    t.string   "instance_command",    null: false
    t.string   "instance_status",     null: false
    t.integer  "instance_modulo",     null: false
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "receiver_protocols", ["instance_uuid"], name: "index_receiver_protocols_on_instance_uuid", unique: true, using: :btree
  add_index "receiver_protocols", ["receiver_uuid", "instance_modulo"], name: "index_receiver_protocols_on_receiver_uuid_and_instance_modulo", unique: true, using: :btree
  add_index "receiver_protocols", ["receiver_uuid"], name: "index_receiver_protocols_on_receiver_uuid", using: :btree

end
