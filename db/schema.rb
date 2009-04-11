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

ActiveRecord::Schema.define(:version => 20090410210341) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.string   "email",                     :limit => 100
    t.string   "subdomain"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "custom_domain"
    t.string   "domain_type",               :limit => 9,   :default => "subdomain"
  end

  add_index "accounts", ["email"], :name => "index_accounts_on_email"

  create_table "builtin_templates", :force => true do |t|
    t.integer "template_id"
    t.boolean "default_template", :default => false
  end

  create_table "custom_templates", :force => true do |t|
    t.integer "teaser_id"
    t.integer "template_id"
  end

  create_table "subscribers", :force => true do |t|
    t.integer  "teaser_id"
    t.string   "name"
    t.string   "email",      :limit => 100
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscribes", :force => true do |t|
    t.integer "teaser_id"
    t.integer "visitor_id"
    t.integer "subscriber_id"
    t.date    "subscribed_on"
  end

  create_table "teasers", :force => true do |t|
    t.integer  "account_id"
    t.string   "title"
    t.text     "description"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "page_views",        :default => 0
    t.integer  "template_id"
  end

  create_table "templates", :force => true do |t|
    t.string   "name"
    t.text     "source"
    t.text     "styles"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "visitors", :force => true do |t|
    t.integer "teaser_id"
    t.string  "cookie"
  end

  create_table "visits", :force => true do |t|
    t.integer  "visitor_id"
    t.datetime "visited_at"
  end

end
