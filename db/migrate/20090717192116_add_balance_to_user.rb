class AddBalanceToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :balance, :integer, :default => 0
  end

  def self.down
    remove_column :users, :balance
  end
end
