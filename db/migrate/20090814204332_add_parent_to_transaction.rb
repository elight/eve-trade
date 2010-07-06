class AddParentToTransaction < ActiveRecord::Migration
  def self.up
    add_column :transactions, :parent_id, :integer
  end

  def self.down
    remove_column :transactions, :parent_id
  end
end
