class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.integer :price_per_share, :null => false, :limit => 8
      t.integer :total_shares, :null => false
      t.integer :remaining_shares, :null => false
      t.integer :user_id, :null => false
      t.integer :stock_id, :null => false
      t.datetime :expires_at
      t.string :type
      t.timestamps
    end

    add_index :orders, :price_per_share
    add_index :orders, :total_shares
    add_index :orders, :remaining_shares
    add_index :orders, :user_id
    add_index :orders, :stock_id
  end

  def self.down
    remove_index :orders, :price_per_share
    remove_index :orders, :total_shares
    remove_index :orders, :remaining_shares
    remove_index :orders, :user_id
    remove_index :orders, :stock_id
    drop_table :orders
  end
end
