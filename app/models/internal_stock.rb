class InternalStock < Stock
  validates_numericality_of :number_of_shares, :initial_price

  def market_value
    current_value
  end
end
