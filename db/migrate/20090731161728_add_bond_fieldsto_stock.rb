class AddBondFieldstoStock < ActiveRecord::Migration
  def self.up
    add_column :stocks, :initial_interest_rate, :float
    add_column :stocks, :refundable_early, :boolean
    add_column :stocks, :resellable, :boolean, :default => true
    add_column :stocks, :months_until_maturity, :integer
    add_column :stocks, :bonus_rate_period, :integer
    add_column :stocks, :bonus_rate, :float
    add_column :stocks, :period_length, :integer
    add_column :stocks, :interest_increment, :float
  end

  def self.down
    remove_column :stocks, :initial_interest_rate
    remove_column :stocks, :refundable_early
    remove_column :stocks, :resellable
    remove_column :stocks, :matures_on
    remove_column :stocks, :bonus_rate_period
    remove_column :stocks, :bonus_rate
    remove_column :stocks, :period_length
    remove_column :stocks, :interest_increment
  end
end
