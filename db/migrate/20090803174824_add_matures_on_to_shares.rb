class AddMaturesOnToShares < ActiveRecord::Migration
  def self.up
    add_column :shares, :matures_on, :datetime
    add_column :shares, :type, :string
    shares = Share.find(:all, :include => :stock)
    shares.each do |share|
      if share.stock.is_a? Bond
        share.matures_on = share.created_at + share.stock.months_until_maturity.months
        share.type = "BondShare"
        share.save!
      end
    end
    remove_column :stocks, :resellable
  end

  def self.down
    remove_column :shares, :matures_on
    remove_column :shares, :type
    add_column :stocks, :resellable, :boolean, :default => false
  end
end
