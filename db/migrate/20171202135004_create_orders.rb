class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :order_id
      t.string :currency_pair
      t.string :action
      t.decimal :amount, precision: 10, scale: 4 # btc_jpy : 0.0001BTC単位
      t.decimal :price
      t.decimal :fee
      t.string :your_action
      t.decimal :bonus

      t.timestamps null: false
    end
  end
end
