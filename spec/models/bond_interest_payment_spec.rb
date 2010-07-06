require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe Bond do
  describe "when processing a bond interest payment" do
    before do
      @bond_issuer = Factory(:eve_user, :balance => 55_000_000)
      @bond_holder = Factory(:eve_user, :balance => 10_000_000)
      @bond = Factory(:bond, :ceo_id => @bond_issuer.id, :initial_price => 42_000, :initial_interest_rate => 5.0)
      @bond_share = Factory(:bond_share, :stock_id => @bond.id, :user_id => @bond_holder.id, :matures_on => 3.months.from_now)
      # Reload because issuer created a Bond and was thus charged a fee
      @bond_issuer.reload
      @bond_issuer_initial_balance = @bond_issuer.balance
      @bond_holder_initial_balance = @bond_holder.balance
      @interest_payment = (@bond.initial_price * @bond.initial_interest_rate * 0.01).floor
    end

    describe "and the bond holder can afford the interest payment" do
      before do
        Bond.pay_interest_on(@bond_share, 1)
        @bond_issuer.reload
        @bond_holder.reload
      end

      it "should have increased the bond holder's balance by the amount of the interest payment" do
        @bond_holder.balance.should == @bond_holder_initial_balance + @interest_payment
      end

      it "should have decreased the bond issuer's balance by the amount of the interest payment" do
        @bond_issuer.balance.should == @bond_issuer_initial_balance - @interest_payment
      end

      it "should have created a record of the successful interest payment" do
        InterestPayment.count.should == 1
      end

      it "should have logged the correct amount for the interest payment" do
        InterestPayment.first.amount.should == @interest_payment
      end

      it "should have logged the correct payer" do
        InterestPayment.first.payer.should == @bond_issuer
      end

      it "should have logged the correct payee" do
        InterestPayment.first.payee.should == @bond_holder
      end
    end

    describe "and the bond holder cannot afford the interest payment" do
      before do
        @bond_issuer = @bond_share.stock.ceo
        @bond_issuer_initial_balance = @bond_issuer.balance = 0
        @bond_issuer.save!
        Bond.pay_interest_on(@bond_share, 1)
        @bond_issuer.reload
        @bond_holder.reload
      end

      it "should have created a record of the failed interest payment" do
        FailedInterestPayment.count.should == 1
      end

      it "should have logged the amount of the failed payment" do
        FailedInterestPayment.first.amount.should == @interest_payment
      end

      it "should not have changed the bond issuer's balance" do
        @bond_issuer.balance.should == @bond_issuer_initial_balance
      end

      it "should not have changed the bond holder's balance" do
        @bond_holder.balance.should == @bond_holder_initial_balance
      end
    end
  end
end
