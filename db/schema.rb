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

ActiveRecord::Schema.define(version: 20150112155503) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "facebook_accounts", force: :cascade do |t|
    t.string   "facebook_id"
    t.string   "access_token"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "image_url"
    t.integer  "user_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "link_posts", force: :cascade do |t|
    t.integer  "link_id"
    t.integer  "user_id"
    t.boolean  "owned",               default: true
    t.datetime "posted_at"
    t.string   "post_id"
    t.json     "post_data"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "facebook_account_id"
    t.integer  "twitter_account_id"
    t.integer  "linkedin_account_id"
    t.string   "posted_by"
  end

  add_index "link_posts", ["link_id"], name: "index_link_posts_on_link_id", using: :btree
  add_index "link_posts", ["owned"], name: "index_link_posts_on_owned", using: :btree
  add_index "link_posts", ["user_id"], name: "index_link_posts_on_user_id", using: :btree

  create_table "linkedin_accounts", force: :cascade do |t|
    t.string   "linkedin_id"
    t.string   "access_token"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "headline"
    t.string   "image_url"
    t.integer  "user_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "links", force: :cascade do |t|
    t.string   "url"
    t.string   "title"
    t.text     "description"
    t.string   "image_url"
    t.string   "content_type"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "twitter_accounts", force: :cascade do |t|
    t.string   "twitter_id"
    t.string   "username"
    t.string   "access_token"
    t.string   "access_token_secret"
    t.string   "image_url"
    t.integer  "user_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
