class Withdrawal < Transaction
  belongs_to :payee, :class_name => "User"

  validates_presence_of :payee_id, :state
  validates_numericality_of :amount

  named_scope :pending, :conditions => "state = 'pending'"

  def validate
    if amount % 1.0 > 0
      errors.add(:amount, "must be a positive integer")
    elsif amount <= 0
      errors.add(:amount, "must be a positive integer")
    end
  end

  def pending?
    self.state == "pending"
  end

  def complete
    if self.pending?
      transaction do
        payee.balance -= self.amount
        payee.save!
        self.state = "complete"
        self.save!
      end
    else
      logger.warn("This withdrawal was already completed on #{self.updated_at}")
      false
    end
  end
end
