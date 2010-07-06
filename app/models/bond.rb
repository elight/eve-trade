class Bond < Stock
  belongs_to :ceo, :class_name => "User"

  validates_presence_of :initial_interest_rate
  validates_numericality_of :initial_interest_rate

  def validate
    super
    if self.months_until_maturity && self.months_until_maturity <= 0
      errors.add(:months_until_maturity, "must be a positive whole number")
    end

    if self.bonus_rate && self.bonus_rate_period.nil? 
      errors.add(:bonus_rate_period, "required if you have a bonus rate")
    elsif self.bonus_rate.nil? && self.bonus_rate_period
      errors.add(:bonus_rate, "required if you have a bonus rate period")
    end
    if self.interest_increment && self.period_length.nil? 
      errors.add(:period_length, "required if you have specified an interest rate increment")
    elsif self.interest_increment.nil? && self.period_length
      errors.add(:interest_increment, "required if you have specified the number of period between interest increments")
    end

    if self.initial_interest_rate && self.initial_interest_rate <= 0
      errors.add(:initial_interest_rate, "must be a positive floating point value")
    end
    if self.bonus_rate && self.bonus_rate <= 0
      errors.add(:bonus_rate, "must be a positive floating point value")
    end
    if self.interest_increment && self.interest_increment <= 0
      errors.add(:interest_increment, "must be a positive floating point value")
    end

    true
  end

  def mature_shares?
    shares.find(:all, :joins => :stock, :conditions => ["user_id != stocks.ceo_id and shares.created_at <= ? and stocks.type = ?", Time.now - months_until_maturity.months, "Bond"])
  end

  def self.mature_shares
    # TODO: Need a column on shares to indicate when they become mature
    Share.find(:all, :joins => :stock, :conditions => ["user_id != stocks.ceo_id and shares.created_at <= ? and stocks.type = ?", Time.now , "Bond"])
  end

  def self.shares_that_will_mature_in(time)
    Share.that_will_mature_in(time)
  end

  def self.repay(bond_share)
    args = {
      :payer => bond_share.stock.ceo,
      :payee => bond_share.user,
      :stock => bond_share.stock,
      :amount => bond_share.market_value,
      :number_of_shares => bond_share.number
    }
    repayment = BondRepayment.new(args)
    # Bond is completed so remove the shares
    if repayment.save
      bond_share.destroy
    else
      repayment = FailedBondPayment.create(args)
      # for subscription users
      #UserMailer.notify_ceo_of_failed_repayment_of(bond_share)
      #UserMailer.notify_holder_of_failed_repayment(bond_share)
    end
    repayment
  end

  def self.pay_interest_on(bond_share, month)
    args = {
      :payer => bond_share.stock.ceo,
      :payee => bond_share.user,
      :stock => bond_share.stock,
      :amount => bond_share.interest_payout_for_month(month),
      :number_of_shares => bond_share.number
    }
    payment = InterestPayment.new(args)
    # Bond is completed so remove the shares
    unless payment.save
      payment = FailedInterestPayment.create(args)
      # for subscription users
      #UserMailer.notify_ceo_of_failed_repayment_of(bond_share)
      #UserMailer.notify_holder_of_failed_repayment(bond_share)
    end
    payment
  end

  def self.refund(bond_share)
    amount_to_repay = bond_share.market_value
    refund = BondRefund.new(
      :payer => bond_share.stock.ceo,
      :payee => bond_share.user,
      :stock => bond_share.stock,
      :amount => amount_to_repay,
      :number_of_shares => bond_share.number
    )
    if refund.save
      # Bond is completed so remove the shares
      bond_share.destroy
    end
    refund
  end

  def market_value
    initial_price
  end

  def interest_payout_for_month(month)
    current_value = initial_price
    current_rate = initial_interest_rate
    if period_length
      current_rate += ((month * 1.0 / period_length).floor) * interest_increment
    end
    if bonus_rate_period && bonus_rate_period <= month
      current_rate += bonus_rate
    end
    (initial_price * current_rate * 0.01).to_i 
  end

end
