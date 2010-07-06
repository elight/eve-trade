class InitialSellOrder < SellOrder
  def creation_fee
    Fee::INITIAL_SELL_ORDER_FEE
  end
end
