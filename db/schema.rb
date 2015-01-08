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

ActiveRecord::Schema.define(version: 20150108212720) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "link_posts", force: :cascade do |t|
    t.integer  "link_id"
    t.integer  "user_id"
    t.text     "sources",    default: [],                array: true
    t.boolean  "owned",      default: true
    t.datetime "posted_at"
    t.string   "post_id"
    t.json     "post_data"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "link_posts", ["link_id"], name: "index_link_posts_on_link_id", using: :btree
  add_index "link_posts", ["owned"], name: "index_link_posts_on_owned", using: :btree
  add_index "link_posts", ["user_id"], name: "index_link_posts_on_user_id", using: :btree

  create_table "links", force: :cascade do |t|
    t.string   "url"
    t.string   "title"
    t.text     "description"
    t.string   "image_url"
    t.string   "content_type"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "twitter_id"
    t.string   "twitter_username"
    t.string   "twitter_access_token"
    t.string   "twitter_access_token_secret"
    t.string   "email"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "facebook_id"
    t.string   "facebook_access_token"
  end

end
