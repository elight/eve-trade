class CreateStocks < ActiveRecord::Migration
  def self.up
    create_table :stocks do |t|
      t.string :name, :null => false
      t.string :symbol, :null => false
      t.string :stock_type
      t.integer :number_of_shares
      t.integer :initial_price, :limit => 8
      t.timestamps
    end
  end

  def self.down
    drop_table :stocks
  end
end
