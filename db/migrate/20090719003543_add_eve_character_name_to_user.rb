class AddEveCharacterNameToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :eve_character_name, :string, :null => false
  end

  def self.down
    remove_column :users, :eve_character_name
  end
end
