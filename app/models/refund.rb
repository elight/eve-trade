class Refund < Transaction
  validates_presence_of :payer_name, :amount, :status
  validates_numericality_of :amount

  before_create do
    state = "pending"
  end

  def complete
    if self.pending?
      transaction do
        state = "complete"
        save!
      end
    else
      logger.warn("This refund was already completed on #{self.updated_at}")
      false
    end
  end

end
