# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 2) do

  create_table "taskitems", :force => true do |t|
    t.integer  "tasklist_id"
    t.integer  "user_id"
    t.string   "title"
    t.text     "notes"
    t.text     "notes_html"
    t.integer  "complete",    :default => 0
    t.integer  "position"
    t.datetime "due_on"
    t.datetime "created_on"
    t.datetime "updated_on"
  end

  create_table "tasklists", :force => true do |t|
    t.integer  "user_id"
    t.string   "name",             :limit => 100
    t.string   "title",            :limit => 100
    t.text     "description"
    t.text     "description_html"
    t.integer  "is_public",                       :default => 0
    t.integer  "is_shared",                       :default => 0
    t.integer  "position"
    t.integer  "do_notification",                 :default => 0
    t.integer  "view_in_sidebar",                 :default => 1
    t.datetime "created_on"
    t.datetime "updated_on"
  end

  create_table "tasklists_users", :force => true do |t|
    t.integer "tasklist_id"
    t.integer "user_id"
  end

  create_table "users", :force => true do |t|
    t.string   "name",               :limit => 100
    t.string   "email"
    t.string   "login",              :limit => 80
    t.string   "password",           :limit => 40
    t.string   "remembrall",         :limit => 40
    t.datetime "remembrall_expired"
    t.integer  "admin",                             :default => 0
    t.text     "prefs"
    t.datetime "last_login"
    t.datetime "created_on"
    t.datetime "updated_on"
  end

end
