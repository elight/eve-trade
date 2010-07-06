require 'forwardable'


class Share < ActiveRecord::Base
  extend Forwardable

  belongs_to :user
  belongs_to :stock

  validates_presence_of :number, :user_id, :stock_id
  validates_numericality_of :number, :number_for_sale

  def_delegators :stock, :symbol, :current_bid, :current_ask, :last_trade

  def self.that_will_mature_in(time)
    Share.find(:all, :joins => :stock, :conditions => ["user_id != stocks.ceo_id && created_at <= ? and stocks.type = ?", Time.now - time, "Bond"])
  end

  def after_save
    self.destroy if self.number == 0
  end

  def validate
    if number_for_sale > number
      errors.add(:number_for_sale, "may not exceed number of shares in hand")
    end
  end

  def pay_out_per_share(amount)
    if amount <= 0
      logger.error("Paying out a dividend of #{amount}. WTF?")
      return
    end
    transaction do 
      payer = stock.ceo
      if payer.balance <= self.market_value
        return nil
      end
      DividendPayment.create!(:payer => payer, :payee => user, :amount => amount * number, :stock_id => stock.id, :number_of_shares => number)
    end
    amount * number
  end

  def months_since_purchase
    ((Time.now - self.created_at).to_i / 1.month.to_i).floor
  end

  def market_value
    stock.market_value * number
  end
end
