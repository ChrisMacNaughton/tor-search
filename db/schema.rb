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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130810150354) do

  create_table "admin_searches", :force => true do |t|
    t.integer "admin_id"
    t.string  "controller_class"
    t.text    "search_params"
    t.text    "sort_params"
  end

  create_table "admins", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "admins", ["email"], :name => "index_admins_on_email", :unique => true
  add_index "admins", ["reset_password_token"], :name => "index_admins_on_reset_password_token", :unique => true

  create_table "clicks", :force => true do |t|
    t.integer  "search_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.text     "target",     :default => ""
  end

  add_index "clicks", ["search_id"], :name => "index_clicks_on_search_id"

  create_table "content_flags", :force => true do |t|
    t.text     "reason"
    t.string   "content_type"
    t.integer  "content_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "flag_reason_id"
  end

  create_table "crawler_log_entries", :force => true do |t|
    t.string   "type_str"
    t.string   "action"
    t.string   "reason"
    t.integer  "page_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",     :default => 0, :null => false
    t.integer  "attempts",     :default => 0, :null => false
    t.text     "handler",                     :null => false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.string   "handler_hash"
  end

  add_index "delayed_jobs", ["handler_hash"], :name => "index_delayed_jobs_on_handler_hash"
  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "documents", :force => true do |t|
    t.text     "path"
    t.integer  "domain_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "documents", ["path", "domain_id"], :name => "index_documents_on_path_and_domain_id", :unique => true
  add_index "documents", ["path"], :name => "index_documents_on_path"

  create_table "domains", :force => true do |t|
    t.string   "path"
    t.datetime "last_crawled"
    t.decimal  "domain_rank"
    t.boolean  "will_index"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.text     "robots"
    t.datetime "last_robots_check"
    t.integer  "missed_attempts",   :default => 0
    t.boolean  "blocked",           :default => false
    t.boolean  "pending",           :default => false
    t.boolean  "disabled",          :default => false
  end

  add_index "domains", ["path"], :name => "index_domains_on_path", :unique => true

  create_table "flag_reasons", :force => true do |t|
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "images", :force => true do |t|
    t.text     "path"
    t.string   "thumbnail_path"
    t.integer  "domain_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "alt_text",           :default => ""
    t.string   "unique_hash",        :default => ""
    t.boolean  "no_crawl",           :default => false
    t.datetime "last_crawled"
    t.boolean  "disabled",           :default => false
  end

  add_index "images", ["path", "domain_id"], :name => "index_images_on_path_and_domain_id", :unique => true
  add_index "images", ["path"], :name => "index_images_on_path"

  create_table "links", :force => true do |t|
    t.integer  "from_target_id"
    t.integer  "to_target_id"
    t.text     "anchor_text"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "from_target_type", :default => "Page"
    t.string   "to_target_type",   :default => "Page"
  end

  add_index "links", ["from_target_id"], :name => "index_links_on_from_target_id"
  add_index "links", ["to_target_id"], :name => "index_links_on_to_target_id"

  create_table "messages", :force => true do |t|
    t.string   "name"
    t.text     "text"
    t.text     "contact_method"
    t.boolean  "advertising"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "pages", :force => true do |t|
    t.text     "path"
    t.integer  "domain_id"
    t.string   "title"
    t.text     "description"
    t.text     "meta_keywords"
    t.text     "meta_generator"
    t.datetime "last_crawled"
    t.decimal  "page_rank"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.boolean  "no_crawl",       :default => false
    t.text     "body"
    t.string   "unique_hash",    :default => ""
    t.integer  "duplicate_id"
  end

  add_index "pages", ["path", "domain_id"], :name => "index_pages_on_path_and_domain_id", :unique => true
  add_index "pages", ["path"], :name => "index_pages_on_path"
  add_index "pages", ["unique_hash"], :name => "index_pages_on_unique_hash"

  create_table "queries", :force => true do |t|
    t.text     "term"
    t.integer  "searches_count", :default => 0
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "searches", :force => true do |t|
    t.integer  "results_count"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "clicks_count",  :default => 0
    t.integer  "query_id"
  end

end
