class AuditRequest < Fee
  belongs_to :payer, :class_name => "User"
  belongs_to :stock

  validates_presence_of :payer_id, :stock_id, :amount
  validates_numericality_of :amount

  def before_validation_on_create
    super
    state = 'pending'
  end

  def complete
    state = 'complete'
    save!
  end
end
