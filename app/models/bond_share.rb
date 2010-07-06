class BondShare < Share

  def validate
    if user.id != stock.ceo.id && matures_on.nil?
      errors.add(:matures_on, "required for shares not held by the bond manager")
    end
  end

  def interest_payout_for_month(month)
    stock.interest_payout_for_month(month) * self.number
  end
end
