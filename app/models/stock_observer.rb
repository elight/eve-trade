class StockObserver < ActiveRecord::Observer
  def after_create(stock)
    if stock.is_a? Bond
      BondShare.create!(
        :number => stock.number_of_shares,
        :stock_id => stock.id,
        :user_id => stock.ceo.id,
        :matures_on => Time.now + stock.months_until_maturity
      )
    else 
      Share.create!(
        :number => stock.number_of_shares,
        :stock_id => stock.id,
        :user_id => stock.ceo.id
      )
    end
    InitialSellOrder.create!(
      :total_shares => stock.number_of_shares,
      :remaining_shares => stock.number_of_shares,
      :price_per_share => stock.initial_price,
      :user => stock.ceo,
      :stock => stock
    )
  end
end
