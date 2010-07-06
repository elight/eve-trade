require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe Bot do
  fixtures :users

  describe "when processing bond interest payments" do
    describe "and there is a single interest payment due on a single bond" do
      before do
        @bond_issuer = users(:roquezir)
        @bond_issuer.balance = 50_000_000
        @bond_issuer.save!
        @bond_holder = users(:bond_holder)
        @bond = Factory(:bond, :ceo_id => @bond_issuer.id, :initial_price => 42, :initial_interest_rate => 5.0)
        @bond_share = Factory(:bond_share, :stock_id => @bond.id, :user_id => @bond_holder.id, :matures_on => 3.months.from_now)
        @bond_share.created_at = 1.month.ago + 10.minutes
        @bond_share.save!
        @bond_issuer.reload
        @bond_holder_initial_balance = @bond_holder.balance
        @bond_issuer_initial_balance = @bond_issuer.balance
      end

      describe "and the bond holder can afford the interest payment" do
        before do
          @interest_payment = (@bond.initial_price * @bond.initial_interest_rate * 0.01).floor
          Bot.pay_bond_interest
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
      end

      describe "and the bond holder cannot afford the interest payment" do
        it "should have created a record of the failed interest payment"
      end
    end

    describe "and there are several interest payments due on a single bond" do
      before do 
        @issuer = users(:roquezir)
        @issuer.balance = 50_000_000
        @issuer.save!
        @bond = Factory(:bond, :ceo_id => @issuer.id, :initial_price => 42, :initial_interest_rate => 50.0)
        @bond_shares = []
        4.times { @bond_shares << Factory(:bond_share, :stock_id => @bond.id, :user_id => users(:bond_holder).id, :matures_on => 3.months.from_now) }
      end

      describe "and the bond holder can afford the interest payment" do
        it "should have increased the bond holder's balance by the amount of the interest payments"
        it "should have decreased the bond issuer's balance by the amount of the interest payments"
        it "should have created a record of the successful interest payments"
      end

      describe "and the bond holder cannot afford any of the interest payments" do
        it "should have created a record of the failed interest payments"
      end

      describe "and the bond holder cannot afford some of the interest payments" do
        it "should have increased the bond holder's balance by the amount of the interest payments he could afford"
        it "should have decreased the bond issuer's balance by the amount of the interest payments he could afford"
        it "should have created a record of the successful interest payments"
        it "should have created a record of the failed interest payments"
      end
    end
  end
end

