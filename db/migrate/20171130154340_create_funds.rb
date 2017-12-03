class CreateFunds < ActiveRecord::Migration
  def change
    create_table :funds do |t|
      t.string :currency_code
      t.decimal :funds
      t.decimal :deposit

      t.timestamps null: false
    end
  end
end
