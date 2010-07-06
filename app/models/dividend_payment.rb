class DividendPayment < Transaction
  validates_presence_of :amount, :stock_id
  validates_numericality_of :amount, :number_of_shares

  def validate
    if payer.balance < amount
      errors.add(:amount, "is greater than your balance of #{payer.balance}")
    end
    true
  end

  def after_create
    payer.balance -= amount
    payee.balance += amount
    begin
      payer.save!
    rescue Exception => e
      logger.error("Failed to deduct from payer or pay payee for DividendPayment #{self.inspect}")
    end
    begin
      payee.save!
    rescue Exception => e
      logger.error("Failed to pay payee for DividendPayment #{self.inspect}")
    end
  end

  def price_per_share
    amount * 1.0 / number_of_shares
  end
end
