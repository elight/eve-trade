require 'forwardable'

class Order < ActiveRecord::Base
  extend Forwardable

  belongs_to :user
  # should be belongs_to :shares for sell_order
  # need to updates shares.number with number of shares sold at save time...
  # 
  belongs_to :stock

  validates_numericality_of :price_per_share, :total_shares

  def_delegators :stock, :symbol

  def validate_positive_integer(field_name)
    val = self.send(field_name)
    if val < 0
      errors.add(field_name, "cannot be negative")
    end
    if val % 1.0 > 0
      errors.add(field_name, "cannot be a float")
    end
    true
  end

  def creation_fee
    [(total_shares * price_per_share * Fee::ORDER_CREATION_PERCENTAGE).round, Fee::MIN_ORDER_CREATION_FEE].max
  end

  def before_validation_on_create
    fee = creation_fee
    if self.user.balance < fee
      errors.add_to_base("Sorry but your balance of #{user.balance} is too low to pay the transaction fee of #{fee} ISK")
    end
  end

  def validate
    self.remaining_shares = total_shares
    validate_positive_integer(:price_per_share)
    validate_positive_integer(:total_shares)
    validate_positive_integer(:remaining_shares)
    if self.expires_at && self.expires_at < Time.now.beginning_of_day
      errors.add(:expires_at, "cannot be before the current time")
    end
  end

  def after_validation_on_create
    if errors.empty?
      OrderFee.create!(:amount => creation_fee, :stock_id => stock.id, :payer_id => user.id)
    end
  end

  def complete?
    remaining_shares == 0
  end

  def credit_owner_with(amount)
    logger.debug "*** Crediting #{amount} to #{user.eve_character_name}'s balance"
    user.balance += amount
    user.save!
  end

  def finish_transaction!
    destroy if complete?
  end

  def broker_trade!
    logger.debug("*** Brokering deal for #{user.eve_character_name} for #{stock.symbol}")
    best_matches = opposite_type.best_matching_order(self)
    orig_remaining_shares = remaining_shares
    best_matches.each do |other_order|
      logger.debug("*** Talking with #{other_order.user.eve_character_name}")
      transaction do
        quantity = broker_quantity_with(other_order)
        purchase_cost = purchase_cost_for(quantity, other_order)
        logger.debug("*** Determined purchase cost of #{purchase_cost} for #{quantity} shares from #{other_order.user.eve_character_name}")

        if exchange_money(purchase_cost, other_order)
          exchange_shares(quantity, other_order)

          p = create_purchase_for(purchase_cost, quantity, other_order)
          logger.debug(p.inspect)
        end
      end

      begin
        save!
        other_order.save!
      rescue Exception => e
        logger.error(e.message)
        e.backtrace.each { |l| Stock.logger.error(l.to_s) }
      end

      other_order.finish_transaction!
      finish_transaction!
      break if complete?
    end
    orig_remaining_shares - remaining_shares
  end

end
