require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe BondShare do
  describe "when computing an interest payment" do
    describe "for a bond with a flat interest rate" do
      before do
        @bond_issuer = Factory(:eve_user)
        @bond_holder = Factory(:eve_user)
        @bond_issuer.balance = 50_000_000
        @bond_issuer.save!
        @bond = Factory(:bond, :ceo_id => @bond_issuer.id, :initial_price => 42, :initial_interest_rate => 5.0)
        @bond_share = Factory(:bond_share, :stock_id => @bond.id, :user_id => @bond_holder.id, :matures_on => 3.months.from_now)
        # Reload because issuer created a Bond and was thus charged a fee
        @bond_issuer.reload
      end

      it "should calculate the payout to be the floor of the bond price times the interest rate times 0.01" do
        @bond_share.interest_payout_for_month(1).should == (@bond.initial_price * @bond.initial_interest_rate * 0.01).floor
      end
    end
  end
end



