class AddRefIdToTransaction < ActiveRecord::Migration
  def self.up
    add_column :transactions, :ref_id, :integer, :limit => 8
  end

  def self.down
    remove_column :transactions, :ref_id
  end
end
