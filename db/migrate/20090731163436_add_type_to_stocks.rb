class AddTypeToStocks < ActiveRecord::Migration
  def self.up
    remove_column :stocks, :stock_type
    add_column :stocks, :type, :string
  end

  def self.down
    add_column :stocks, :stock_type, :string
    remove_column :stocks, :type
  end
end
