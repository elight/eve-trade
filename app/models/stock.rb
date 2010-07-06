class Stock < ActiveRecord::Base
  belongs_to :ceo, :class_name => "User"
  has_many :shares
  has_many :purchases
  has_many :sell_orders
  has_many :buy_orders
  has_many :dividends
  has_many :articles

  named_scope :ordered_by_created_at, { :order => "created_at DESC" }

  validates_numericality_of :number_of_shares, :initial_price
  validates_presence_of :ceo_id, :name, :symbol, :number_of_shares, :initial_price
  validates_uniqueness_of :name, :symbol

  define_index do
    indexes name
    indexes symbol
    indexes ceo(:eve_character_name), :as => :ceo
    
    set_property :delta => true
  end
  
  def before_validation_on_create
    super
    if self.symbol
      self.symbol.upcase! 
    end
    if ceo.balance < Fee::INITIAL_SELL_ORDER_FEE
      errors.add_to_base("Sorry but your balance of #{ceo.balance} ISK is too low to pay the transaction fee of #{Fee::INITIAL_SELL_ORDER_FEE} ISK to create this product")
      return false
    end
    true
  end

  def validate
    super
    if self.initial_price && self.initial_price <= 0
      errors.add(:initial_price, "Initial price must be a positive whole number")
    end
    if self.number_of_shares && self.number_of_shares <= 0
      errors.add(:number_of_shares, "Number of shares must be a positive whole number")
    end
    true
  end

  def current_value
    return last_trade.price_per_share if last_trade
    0
  end

  def current_dividend
    dividends.find(:first, :order => 'created_at DESC')
  end

  def last_trade
    Purchase.find(:first, :conditions => ['stock_id = ?', self.id], :order => 'created_at DESC') || nil
  end

  def daily_volume
    todays_purchases.inject(0) { |sum, p| sum += p.number_of_shares }
  end

  def average_volume_3_months
    purchases = Purchase.find(:all, :conditions => ['stock_id = ? and created_at >= ?', self.id, Time.now.beginning_of_day - 3.months])
    purchases.inject(0) { |sum, p| sum += p.number_of_shares } / 90.0
  end

  def current_ask
    min_sell_order = SellOrder.find_all_by_stock_id(self.id).min { |o1,o2| o1.price_per_share <=> o2.price_per_share }
    min_sell_order ? min_sell_order.price_per_share : 0
  end

  def current_bid
    max_buy_order = BuyOrder.find_all_by_stock_id(self.id).max { |o1,o2| o1.price_per_share <=> o2.price_per_share } 
    max_buy_order ? max_buy_order.price_per_share : 0
  end

  def todays_range
    todays_activity = todays_purchases
    worst_trade = todays_purchases.min{ |o1,o2| o1.price_per_share <=> o2.price_per_share }
    best_trade = todays_purchases.max{ |o1,o2| o1.price_per_share <=> o2.price_per_share }
    [worst_trade ? worst_trade.price_per_share : 0,
     best_trade ? best_trade.price_per_share : 0]
  end

  def market_cap
    if last_trade
      last_trade.amount * number_of_shares
    else
      0
    end
  end

  def pay_dividends!
    unless dividend = current_dividend
      raise Exception.new("Sorry but you need to set the dividend per share amount before paying dividends")
    end
    logger.debug("Dividend for #{self.symbol} is #{dividend.amount} per share")
    dividend_per_share = dividend.amount
    ceo_shares = shares.find_by_user_id(ceo_id)
    logger.debug("CEO has #{ceo_shares.number} numnber shares of #{self.symbol}")
    number_of_shares_to_pay = self.number_of_shares - ceo_shares.number
    logger.debug("There are #{number_of_shares_to_pay} requiring dividend payments")
    minimum_required_balance = number_of_shares_to_pay * dividend_per_share
    if ceo.balance <= minimum_required_balance
      raise Exception.new("Sorry but your balance is less than the total dividend payment of #{minimum_required_balance}")
    end
    transaction do
      shares_not_belonging_to_ceo.each do |shares|
        shares.pay_out_per_share dividend_per_share
      end
    end
  end

  def shares_not_belonging_to_ceo
    shares.find(:all, :conditions => ["user_id != ?", self.ceo_id])
  end

  def number_shares_for_sale
    SellOrder.find_all_by_stock_id(self.id).inject(0) do |sum, v|
      sum += v.remaining_shares
    end
  end

  private

  def todays_purchases
    Purchase.find(:all, :conditions => ['stock_id = ? and created_at >= ?', self.id, Time.now.beginning_of_day])
  end
end
