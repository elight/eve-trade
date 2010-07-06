class AddFrontpageToArticle < ActiveRecord::Migration
  def self.up
    add_column :articles, :frontpage, :boolean, :default => false
    add_index :articles, :frontpage
  end

  def self.down
    remove_index :articles, :frontpage
    remove_column :articles, :frontpage
  end
end
