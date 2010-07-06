class CreateShares < ActiveRecord::Migration
  def self.up
    create_table :shares do |t|
      t.integer :user_id, :null => false
      t.integer :stock_id, :null => false
      t.integer :number, :null => false
      t.timestamps
    end

    add_index :shares, :stock_id
    add_index :shares, :user_id
  end

  def self.down
    remove_index :shares, :stock_id
    remove_index :shares, :user_id
    drop_table :shares
  end
end
