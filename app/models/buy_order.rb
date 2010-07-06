class BuyOrder < Order
  def self.best_matching_order(sell_order)
    find( :all, :conditions => 
      ["user_id != ? and stock_id = ? and price_per_share <= ?",
        sell_order.user_id,
        sell_order.stock_id,
        sell_order.price_per_share
      ],
      :order => "price_per_share ASC"
    )
  end

  def validate
    if price_per_share * total_shares > user.balance
      errors.add_to_base("Sorry but you cannot open a buy order that is worth more than your current balance")
    end
  end

  def opposite_type
    SellOrder
  end

  def purchase_cost_for(quantity, sell_order)
    sell_order.purchase_cost_for(quantity, self)
  end

  def broker_quantity_with(sell_order)
    if self.remaining_shares >= sell_order.remaining_shares
      quantity = sell_order.remaining_shares
    else
      quantity = remaining_shares
    end
    purchase_cost = sell_order.purchase_cost_for(quantity, self)
    if user.balance < purchase_cost
      quantity = sell_order.how_many_shares_for(user.balance)
    end
    quantity
  end

  def exchange_money(purchase_cost, sell_order)
    if user.balance >= purchase_cost
      self.credit_owner_with(-1 * purchase_cost)
      sell_order.credit_owner_with(purchase_cost)
      true
    end
    false
  end

  def create_purchase_for(purchase_cost, quantity, sell_order)
    Purchase.create!(
      :payer => user,
      :payer_name => user.eve_character_name,
      :payee => sell_order.user,
      :amount => purchase_cost,
      :stock => stock,
      :number_of_shares => quantity
    )
  end

  def exchange_shares(quantity, sell_order)
    shares = nil
    if self.stock.is_a? Bond
      shares = BondShare.new(
        :user => self.user,
        :stock => self.stock,
        :number => 0,
        :matures_on => Time.now + self.stock.months_until_maturity
      )
    else
      shares = self.user.shares.find_by_stock_id(self.stock.id)
      if shares.nil?
        shares = self.user.shares.new(
          :stock => self.stock,
          :number => 0
        )
      end
    end
    logger.debug("*** User #{self.user.eve_character_name} currently has #{shares.number} of #{stock.symbol}")
    shares.number += quantity
    logger.debug("*** User #{self.user.eve_character_name}, after trade, now has #{shares.number} of #{stock.symbol}")
    begin
      shares.save!
    rescue Exception => e
      logger.error(e.message)
      e.backtrace.each { |l| Stock.logger.error(l.to_s) }
    end
    self.remaining_shares -= quantity
    logger.debug("*** Reducing number of shares to purchase by #{quantity} to #{self.remaining_shares}")
    sell_order.decrement_order_share_counters(quantity)
  end
end
