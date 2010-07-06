class CreateTransactions < ActiveRecord::Migration
  def self.up
    create_table :transactions do |t|
      t.integer :payer_id
      t.string :payer_name
      t.integer :payee_id
      t.integer :amount
      t.integer :stock_id
      t.integer :number_of_shares
      t.datetime :occurred_at
      t.string :state
      t.string :type
      t.timestamps
    end

    add_index :transactions, :stock_id
    add_index :transactions, :payer_id
    add_index :transactions, :payee_id
    add_index :transactions, :created_at
    add_index :transactions, :occurred_at
  end

  def self.down
    remove_index :transactions, :stock_id
    remove_index :transactions, :payer_id
    remove_index :transactions, :payee_id
    remove_index :transactions, :created_at
    remove_index :transactions, :occurred_at
    drop_table :transactions
  end
end
