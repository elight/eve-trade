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

ActiveRecord::Schema.define(:version => 20090814204332) do

  create_table "advertisements", :force => true do |t|
    t.string   "image_url"
    t.string   "link_url"
    t.string   "alt_text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "articles", :force => true do |t|
    t.string   "headline",                          :null => false
    t.text     "body",                              :null => false
    t.integer  "stock_id",                          :null => false
    t.integer  "user_id",                           :null => false
    t.string   "state",      :default => "pending", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "frontpage",  :default => false
  end

  add_index "articles", ["frontpage"], :name => "index_articles_on_frontpage"

  create_table "dividends", :force => true do |t|
    t.integer  "stock_id",   :null => false
    t.float    "amount",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", :force => true do |t|
    t.integer  "price_per_share",  :limit => 8, :null => false
    t.integer  "total_shares",                  :null => false
    t.integer  "remaining_shares",              :null => false
    t.integer  "user_id",                       :null => false
    t.integer  "stock_id",                      :null => false
    t.datetime "expires_at"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "orders", ["price_per_share"], :name => "index_orders_on_price_per_share"
  add_index "orders", ["remaining_shares"], :name => "index_orders_on_remaining_shares"
  add_index "orders", ["stock_id"], :name => "index_orders_on_stock_id"
  add_index "orders", ["total_shares"], :name => "index_orders_on_total_shares"
  add_index "orders", ["user_id"], :name => "index_orders_on_user_id"

  create_table "portfolios", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shares", :force => true do |t|
    t.integer  "user_id",                        :null => false
    t.integer  "stock_id",                       :null => false
    t.integer  "number",                         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "number_for_sale", :default => 0
    t.datetime "matures_on"
    t.string   "type"
  end

  add_index "shares", ["stock_id"], :name => "index_shares_on_stock_id"
  add_index "shares", ["user_id"], :name => "index_shares_on_user_id"

  create_table "stocks", :force => true do |t|
    t.string   "name",                                                 :null => false
    t.string   "symbol",                                               :null => false
    t.integer  "number_of_shares"
    t.integer  "initial_price",         :limit => 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ceo_id",                                               :null => false
    t.boolean  "delta",                              :default => true
    t.float    "initial_interest_rate"
    t.boolean  "refundable_early"
    t.integer  "months_until_maturity"
    t.integer  "bonus_rate_period"
    t.float    "bonus_rate"
    t.integer  "period_length"
    t.float    "interest_increment"
    t.string   "type"
  end

  create_table "transactions", :force => true do |t|
    t.integer  "payer_id"
    t.string   "payer_name"
    t.integer  "payee_id"
    t.integer  "amount",           :limit => 8
    t.integer  "stock_id"
    t.integer  "number_of_shares"
    t.datetime "occurred_at"
    t.string   "state"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "payer_eve_id"
    t.integer  "ref_id",           :limit => 8
    t.integer  "parent_id"
  end

  add_index "transactions", ["created_at"], :name => "index_transactions_on_created_at"
  add_index "transactions", ["occurred_at"], :name => "index_transactions_on_occurred_at"
  add_index "transactions", ["payee_id"], :name => "index_transactions_on_payee_id"
  add_index "transactions", ["payer_id"], :name => "index_transactions_on_payer_id"
  add_index "transactions", ["stock_id"], :name => "index_transactions_on_stock_id"

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "state",                                    :default => "passive"
    t.datetime "deleted_at"
    t.integer  "eve_character_id",                                                :null => false
    t.integer  "balance",                   :limit => 8,   :default => 0
    t.string   "eve_character_name",                                              :null => false
    t.boolean  "is_admin",                                 :default => false
    t.string   "password_reset_code",       :limit => 40
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
