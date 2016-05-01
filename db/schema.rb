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

ActiveRecord::Schema.define(version: 20160501233349) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "learner_pools", force: :cascade do |t|
    t.string   "uuid",       limit: 36, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "learner_pools", ["uuid"], name: "index_learner_pools_on_uuid", unique: true, using: :btree

  create_table "learner_pools_learners", id: false, force: :cascade do |t|
    t.integer "learner_id",      null: false
    t.integer "learner_pool_id", null: false
  end

  add_index "learner_pools_learners", ["learner_id"], name: "index_learner_pools_learners_on_learner_id", using: :btree
  add_index "learner_pools_learners", ["learner_pool_id"], name: "index_learner_pools_learners_on_learner_pool_id", using: :btree

  create_table "learners", force: :cascade do |t|
    t.string   "uuid",       limit: 36, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "learners", ["uuid"], name: "index_learners_on_uuid", unique: true, using: :btree

  create_table "question_pools", force: :cascade do |t|
    t.string   "uuid",       limit: 36, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "question_pools", ["uuid"], name: "index_question_pools_on_uuid", unique: true, using: :btree

  create_table "question_pools_questions", id: false, force: :cascade do |t|
    t.integer "question_id",      null: false
    t.integer "question_pool_id", null: false
  end

  add_index "question_pools_questions", ["question_id"], name: "index_question_pools_questions_on_question_id", using: :btree
  add_index "question_pools_questions", ["question_pool_id"], name: "index_question_pools_questions_on_question_pool_id", using: :btree

  create_table "questions", force: :cascade do |t|
    t.string   "uuid",       limit: 36, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "questions", ["uuid"], name: "index_questions_on_uuid", unique: true, using: :btree

end
