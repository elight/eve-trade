class SellOrder < Order
  def self.best_matching_order(buy_order)
    find( :all, :conditions => 
      ["user_id != ? and stock_id = ? and price_per_share <= ?",
        buy_order.user_id, 
        buy_order.stock_id,
        buy_order.price_per_share
      ],
      :order => "price_per_share ASC"
    )
  end

  def opposite_type
    BuyOrder
  end

  def before_validation_on_create
    super
    shares = user.shares.find_by_stock_id(stock_id)
    unless self.total_shares
      errors.add(:total_shares, "must be present to create a sell order")
      return false
    end
    shares.number_for_sale += self.total_shares
    unless shares.save
      errors.add(:total_shares, "cannot exceed number of owned shares plus number of shares on existing sell orders")
      return false
    end
    true
  end

  def after_destroy
    begin
      shares = user.shares.find_by_stock_id(stock_id)
      if shares
        shares.number_for_sale -= self.remaining_shares
        shares.save!
      end
    rescue Exception => e
      logger.error(e.message)
      e.backtrace.each { |l| Stock.logger.error(l.to_s) }
    end
  end

  def broker_quantity_with(buy_order)
    buy_order.broker_quantity_with(self)
  end

  def exchange_money(purchase_cost, buy_order)
    buy_order.exchange_money(purchase_cost, self)
  end

  def exchange_shares(quantity, buy_order)
    buy_order.exchange_shares(quantity, self)
  end

  def create_purchase_for(purchase_cost, quantity, buy_order)
    buy_order.create_purchase_for(purchase_cost, quantity, self)
  end

  def purchase_cost_for(quantity, buy_order)
    if quantity > remaining_shares 
      raise Exception.new("Attempting to purchase more shares than Sell Order has")
    end
    quantity = quantity <= remaining_shares ? quantity : remaining_shares
    quantity * price_per_share
  end

  def how_many_shares_for(amount)
    (amount * 1.0 / price_per_share).floor
  end

  def decrement_order_share_counters(quantity)
    self.remaining_shares -= quantity
    logger.debug("*** Reduced #{self.user.eve_character_name}'s number of #{self.stock.symbol} remaining on this sell order by #{quantity} from #{self.remaining_shares_was} to #{self.remaining_shares}")
    shares = user.shares.find_by_stock_id(stock.id)
    shares.number_for_sale -= quantity
    logger.debug("*** Reduced #{self.user.eve_character_name}'s number of #{self.stock.symbol} for sale by #{quantity} from #{shares.number_for_sale_was} to #{shares.number_for_sale}")
    shares.number -= quantity
    logger.debug("*** Reduced #{self.user.eve_character_name}'s number of #{self.stock.symbol} shares owned by #{quantity} from #{shares.number_was} to #{shares.number}")
    begin
      save!
      shares.save!
    rescue Exception => e
      logger.error(e.message)
      e.backtrace.each { |l| Stock.logger.error(l.to_s) }
    end
  end
end
