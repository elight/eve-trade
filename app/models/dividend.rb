class Dividend < ActiveRecord::Base
  belongs_to :stock

  validates_presence_of :amount, :stock_id
  validates_numericality_of :amount

  def validate
    unless self.amount >= 0
      errors.add(:amount, "Cannot be 0 or negative")
    end
  end
end
