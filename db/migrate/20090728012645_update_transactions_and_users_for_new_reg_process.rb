class UpdateTransactionsAndUsersForNewRegProcess < ActiveRecord::Migration
  def self.up
    add_column :transactions, :payer_eve_id, :integer
    remove_column :users, :eve_api_key
    remove_column :users, :eve_user_id
  end

  def self.down
    remove_column :transactions, :payer_eve_id
    add_column :users, :eve_user_id, :string
    add_column :users, :eve_user_id, :string
  end
end
