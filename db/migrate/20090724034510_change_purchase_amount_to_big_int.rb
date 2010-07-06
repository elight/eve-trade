class ChangePurchaseAmountToBigInt < ActiveRecord::Migration
  def self.up
    change_column :transactions, :amount, :integer, :limit => 8
  end

  def self.down
    change_column :transactions, :amount, :integer
  end
end
