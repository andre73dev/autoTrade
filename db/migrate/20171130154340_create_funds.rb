class CreateFunds < ActiveRecord::Migration
  def change
    create_table :funds do |t|
      t.decimal :funds
      t.decimal :deposit
      t.integer :order_no
      t.integer :order_no_total
      t.string :currency_pair
      t.string :action
      t.decimal :amount, precision: 10, scale: 4 # btc_jpy : 0.0001BTC単位
      t.decimal :price

      t.timestamps null: false
    end
  end
end
