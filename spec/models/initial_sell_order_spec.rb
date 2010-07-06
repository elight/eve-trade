require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe Stock do
  describe "created by a CEO with enough money to pay the fee of #{Fee::INITIAL_SELL_ORDER_FEE}"do
    before do
      ceo = Factory(:eve_user, :balance => Fee::INITIAL_SELL_ORDER_FEE)
      @stock = Factory(:stock, :ceo => ceo)
      @orders = InitialSellOrder.find_all_by_stock_id(@stock.id)
      @shares = Share.find_all_by_stock_id(@stock.id)
    end

    it "should exist" do
      @stock.should_not be_nil
    end

    it "should have a single sell order" do
      @orders.size.should == 1
    end

    it "should have one set of shares" do
      @shares.size.should == 1
    end
  end

  describe "created by a CEO without enough money to pay the fee of #{Fee::INITIAL_SELL_ORDER_FEE}"do
    it "should not exist" do
      lambda { @stock = Factory(:stock, :ceo => ceo) }.should raise_error
    end
  end
end
