class AddDeltaToStocks < ActiveRecord::Migration
  def self.up
    add_column :stocks, :delta, :boolean, :default => true
  end

  def self.down
    remove_column :stocks, :delta
  end
end
