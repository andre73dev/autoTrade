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

ActiveRecord::Schema.define(version: 20171202135004) do

  create_table "funds", force: :cascade do |t|
    t.string   "currency_code"
    t.decimal  "funds"
    t.decimal  "deposit"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "order_id"
    t.string   "currency_pair"
    t.string   "action"
    t.decimal  "amount",        precision: 10, scale: 4
    t.decimal  "price"
    t.decimal  "fee"
    t.string   "your_action"
    t.decimal  "bonus"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "tickers", force: :cascade do |t|
    t.string   "cur_code"
    t.string   "ctr_cur_code"
    t.decimal  "last"
    t.decimal  "high"
    t.decimal  "low"
    t.decimal  "vwap"
    t.decimal  "volume"
    t.decimal  "bid"
    t.decimal  "ask"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

end
