class Purchase < Transaction
  belongs_to :stock
  belongs_to :payer, :class_name => "User"
  belongs_to :payee, :class_name => "User"

  named_scope :ordered_by_created_at, { :order => "created_at DESC" }
  named_scope :ordered_by_price_per_share, { :order => "(amount / number_of_shares) DESC" }

  validates_presence_of :payer_id, :payee_id, :amount, :stock_id, :number_of_shares
  validates_numericality_of :number_of_shares, :amount

  def validate
    if number_of_shares <= 0
      errors.add(:number_of_shares, "must be a positive integer value") 
    end
    if amount <= 0
      errors.add(:amount, "must be a positive integer value") 
    end
  end

  def price_per_share
    amount / number_of_shares
  end
end
