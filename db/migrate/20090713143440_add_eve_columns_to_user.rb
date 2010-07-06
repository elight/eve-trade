class AddEveColumnsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :eve_api_key, :string, :null => false
    add_column :users, :eve_user_id, :integer, :null => false
    add_column :users, :eve_character_id, :integer, :null => false
  end

  def self.down
    remove_column :users, :eve_api_key
    remove_column :users, :eve_user_id
    remove_column :users, :eve_character_id
  end
end
