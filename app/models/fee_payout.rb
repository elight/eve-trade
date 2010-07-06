require 'yaml'

class FeePayout < Transaction
  belongs_to :payee, :class_name => "User"
  belongs_to :parent, :class_name => "Fee"

  validates_presence_of :amount, :parent_id, :payee_id
  validates_numericality_of :amount

  def self.load_fee_payees
    @payees = YAML.load_file("config/fee_payees.yml")
  end

  def self.payees
    @payees
  end

  def after_validation_on_create
    payee.balance += amount
    unless payee.save
      logger.error("Failed to save payee #{payee.errors.inspect}")
    end
  end
  
  load_fee_payees
end
