class CreateTickers < ActiveRecord::Migration
  def change
    create_table :tickers do |t|
      t.string :cur_code
      t.string :ctr_cut_code
      t.decimal :last
      t.decimal :high
      t.decimal :low
      t.decimal :vwap
      t.decimal :volume
      t.decimal :bid
      t.decimal :ask

      t.timestamps null: false
    end
  end
end
