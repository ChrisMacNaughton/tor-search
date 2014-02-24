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

ActiveRecord::Schema.define(:version => 20140224210650) do

  create_table "ad_campaigns", :force => true do |t|
    t.integer  "advertiser_id"
    t.text     "name"
    t.boolean  "paused",                                       :default => true
    t.datetime "created_at",                                                     :null => false
    t.datetime "updated_at",                                                     :null => false
    t.decimal  "default_bid",   :precision => 16, :scale => 8, :default => 0.0
  end

  add_index "ad_campaigns", ["advertiser_id"], :name => "index_ad_campaigns_on_advertiser_id"

  create_table "ad_clicks", :force => true do |t|
    t.integer  "ad_id"
    t.integer  "query_id"
    t.decimal  "bid",        :precision => 16, :scale => 8, :default => 0.001
    t.datetime "created_at",                                                   :null => false
    t.datetime "updated_at",                                                   :null => false
    t.integer  "search_id"
    t.integer  "keyword_id"
  end

  create_table "ad_group_keywords", :force => true do |t|
    t.integer  "ad_group_id"
    t.integer  "keyword_id"
    t.decimal  "bid",         :precision => 16, :scale => 8
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
    t.boolean  "paused",                                     :default => false
    t.integer  "clicks",                                     :default => 0
    t.integer  "views",                                      :default => 0
  end

  add_index "ad_group_keywords", ["ad_group_id", "keyword_id"], :name => "index_ad_group_keywords_on_ad_group_id_and_keyword_id", :unique => true
  add_index "ad_group_keywords", ["ad_group_id"], :name => "index_ad_group_keywords_on_ad_group_id"
  add_index "ad_group_keywords", ["keyword_id"], :name => "index_ad_group_keywords_on_keyword_id"

  create_table "ad_groups", :force => true do |t|
    t.integer  "ad_campaign_id"
    t.integer  "advertiser_id"
    t.boolean  "paused",                                        :default => true
    t.text     "name"
    t.datetime "created_at",                                                      :null => false
    t.datetime "updated_at",                                                      :null => false
    t.integer  "clicks_count",                                  :default => 0
    t.integer  "views_count",                                   :default => 0
    t.decimal  "ctr",            :precision => 16, :scale => 8, :default => 0.0
    t.decimal  "avg_position",   :precision => 16, :scale => 8, :default => 0.0
  end

  add_index "ad_groups", ["ad_campaign_id"], :name => "index_ad_groups_on_ad_campaign_id"
  add_index "ad_groups", ["advertiser_id"], :name => "index_ad_groups_on_advertiser_id"

  create_table "ad_views", :force => true do |t|
    t.integer  "ad_id"
    t.integer  "query_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "position"
    t.integer  "keyword_id"
  end

  add_index "ad_views", ["ad_id"], :name => "index_ad_views_on_ad_id"
  add_index "ad_views", ["query_id"], :name => "index_ad_views_on_query_id"

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

  create_table "ads", :force => true do |t|
    t.integer  "advertiser_id"
    t.string   "title",           :limit => 25,                                :default => ""
    t.text     "path",                                                         :default => ""
    t.boolean  "disabled",                                                     :default => false
    t.decimal  "bid",                           :precision => 16, :scale => 8, :default => 0.0
    t.datetime "created_at",                                                                      :null => false
    t.datetime "updated_at",                                                                      :null => false
    t.boolean  "approved",                                                     :default => false
    t.integer  "ad_views_count",                                               :default => 0
    t.boolean  "onion",                                                        :default => false
    t.boolean  "ppc",                                                          :default => true
    t.integer  "ad_clicks_count",                                              :default => 0
    t.string   "display_path",    :limit => 35,                                :default => ""
    t.string   "line_1",          :limit => 35,                                :default => ""
    t.string   "line_2",          :limit => 35,                                :default => ""
    t.integer  "protocol_id",                                                  :default => 0
    t.integer  "ad_group_id"
    t.decimal  "avg_position",                  :precision => 16, :scale => 8, :default => 0.0
    t.datetime "deleted_at"
  end

  add_index "ads", ["ad_group_id"], :name => "index_ads_on_ad_group_id"
  add_index "ads", ["advertiser_id"], :name => "index_ads_on_advertiser_id"

  create_table "advertisers", :force => true do |t|
    t.string   "email",                                                 :default => "",    :null => false
    t.string   "encrypted_password",                                    :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                                               :null => false
    t.datetime "updated_at",                                                               :null => false
    t.decimal  "balance",                :precision => 16, :scale => 8, :default => 0.0
    t.string   "username"
    t.boolean  "beta"
    t.boolean  "wants_beta"
    t.boolean  "wants_js",                                              :default => false
    t.boolean  "is_auto_approved",                                      :default => false
  end

  add_index "advertisers", ["reset_password_token"], :name => "index_advertisers_on_reset_password_token", :unique => true
  add_index "advertisers", ["username"], :name => "index_advertisers_on_username", :unique => true

  create_table "banned_domains", :force => true do |t|
    t.string   "hostname",   :null => false
    t.text     "reason"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "bitcoin_addresses", :force => true do |t|
    t.string   "address"
    t.integer  "advertiser_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "bitcoin_addresses", ["advertiser_id"], :name => "index_bitcoin_addresses_on_advertiser_id"

  create_table "clicks", :force => true do |t|
    t.integer  "search_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.text     "target",     :default => ""
  end

  add_index "clicks", ["search_id"], :name => "index_clicks_on_search_id"

  create_table "coupons", :force => true do |t|
    t.string   "code"
    t.decimal  "value",      :precision => 16, :scale => 8, :default => 0.0
    t.datetime "created_at",                                                 :null => false
    t.datetime "updated_at",                                                 :null => false
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

  create_table "domains", :force => true do |t|
    t.string   "path"
    t.boolean  "pending"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "flag_reasons", :force => true do |t|
    t.text     "name"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "flags", :force => true do |t|
    t.integer  "query_id"
    t.integer  "flag_reason_id"
    t.text     "path"
    t.text     "title"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.text     "comments"
  end

  add_index "flags", ["flag_reason_id"], :name => "index_flags_on_flag_reason_id"
  add_index "flags", ["query_id"], :name => "index_flags_on_query_id"

  create_table "instant_results", :force => true do |t|
    t.integer  "query_id"
    t.string   "bang_match"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "keywords", :force => true do |t|
    t.text     "word"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "searches_counts"
    t.integer  "status_id",       :default => 1
  end

  create_table "messages", :force => true do |t|
    t.string   "name"
    t.text     "text"
    t.text     "contact_method"
    t.boolean  "advertising"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "payments", :force => true do |t|
    t.decimal  "amount",             :precision => 16, :scale => 8, :default => 0.0
    t.integer  "advertiser_id"
    t.integer  "bitcoin_address_id"
    t.datetime "created_at",                                                         :null => false
    t.datetime "updated_at",                                                         :null => false
    t.integer  "coupon_id"
    t.string   "transaction_hash"
    t.integer  "parent_id"
  end

  add_index "payments", ["advertiser_id"], :name => "index_payments_on_advertiser_id"
  add_index "payments", ["bitcoin_address_id"], :name => "index_payments_on_bitcoin_address_id"

  create_table "queries", :force => true do |t|
    t.text     "term"
    t.integer  "searches_count", :default => 0
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "queries", ["term"], :name => "index_queries_on_term"

  create_table "rails_admin_histories", :force => true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      :limit => 2
    t.integer  "year",       :limit => 8
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], :name => "index_rails_admin_histories"

  create_table "searches", :force => true do |t|
    t.integer  "results_count"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "clicks_count",  :default => 0
    t.integer  "query_id"
    t.boolean  "paginated",     :default => false
    t.boolean  "js_enabled",    :default => false
  end

end
