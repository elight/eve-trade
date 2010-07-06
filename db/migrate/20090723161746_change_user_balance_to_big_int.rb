class ChangeUserBalanceToBigInt < ActiveRecord::Migration
  def self.up
    change_column :users, :balance, :integer, :limit => 8
  end

  def self.down
    change_column :users, :balance, :integer
  end
end
