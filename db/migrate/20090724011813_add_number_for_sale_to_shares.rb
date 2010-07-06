class AddNumberForSaleToShares < ActiveRecord::Migration
  def self.up
    add_column :shares, :number_for_sale, :integer, :default => 0
  end

  def self.down
    remove_column :shares, :number_for_sale
  end
end
