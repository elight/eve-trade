class Fee < Transaction
  belongs_to :payer, :class_name => "User"
  has_many :fee_payouts, :foreign_key => "parent_id"

  validates_presence_of :payer_id, :amount
  validates_numericality_of :amount

  FEATURED_ARTICLE = 25_000_000
  ORDER_CREATION_PERCENTAGE = 0.01
  MIN_ORDER_CREATION_FEE = 1_000_000
  INITIAL_SELL_ORDER_FEE = 50_000_000
  AUDIT_FEE = 100_000_000

  def before_validation_on_create
    super
    if payer.balance <= amount
      errors.add_to_base("Sorry but your balance of #{payer.balance} ISK is below the requisite amount of #{amount} to perform this operation")
      return false
    end
    true
  end

  def after_create
    transaction do 
      payer.balance -= amount
      payer.save!
      FeePayout.payees.each do |payee_name, percentage|
        payee = User.find_by_eve_character_name(payee_name)
        fee_income_amount = percentage * amount
        payout = fee_payouts.new(
          :amount => fee_income_amount,
          :payer_id => payer.id,
          :payee_id => payee.id,
          :stock_id => stock.id
        )
        unless payout.save
          logger.error("Failed to save payout #{payout.errors.inspect}")
        end
      end
    end
  end
end
