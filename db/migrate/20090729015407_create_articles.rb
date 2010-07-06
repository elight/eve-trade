class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.string :headline, :null => false
      t.text :body, :null => false
      t.integer :stock_id, :null => false
      t.integer :user_id, :null => false
      t.string :state, :null => false, :default => "pending"
      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end
