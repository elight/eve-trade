class AddCeoidToStock < ActiveRecord::Migration
  def self.up
    add_column :stocks, :ceo_id, :integer, :null => false
  end

  def self.down
    remove_column :stocks, :ceo_id
  end
end
