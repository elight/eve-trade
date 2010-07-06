class CreateDividends < ActiveRecord::Migration
  def self.up
    create_table :dividends do |t|
      t.integer :stock_id, :null => false
      t.float :amount, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :dividends
  end
end
