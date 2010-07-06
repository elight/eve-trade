require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe Bot do
  fixtures :users

  share_examples_for "a generic deposit" do
    it "should create a Deposit" do
      Bot.fetch_new_transactions
      Deposit.count.should == 1
    end

    it "should create a Deposit for the user who sent the money" do
      Bot.fetch_new_transactions
      Deposit.first.payer_name.should == @user_name
    end
  
    it "should create a Deposit for the correct amount" do
      Bot.fetch_new_transactions
      Deposit.first.amount.should == @deposit_amount
    end
  end


  describe "with a single deposit in its journal" do
    before do
      @deposit_amount = 5300000
      @user_name = users(:roquezir).eve_character_name
      @user_id = users(:roquezir).eve_character_id
      @result = {
        "eveapi" => {
          "currentTime" => "2008-08-22 12:00:16",
          "result" => {
            "rowset" => {
              "row" => {
                "date" => "2008-08-21 00:12:00",
                "refID" => "1575178039",
                "refTypeID" => "64", 
                "ownerName1" => @user_name,
                "ownerID1" => @user_id.to_s,
                "ownerName2" => "EvETrade Teller",
                "ownerID2" => "43",
                "amount" => @deposit_amount.to_s,
                "balance" => "5300000.00"
              }
            }
          },
          "cachedUntil" => "2008-08-22 12:15:16"
        }
      }
      Bot.stub!(:get).and_return(@result)
    end

    describe "from an existing user" do
      before do
        @user = users(:roquezir)
        @balance = @user.balance
      end

      it_should_behave_like "a generic deposit"

      it "should increase the user's balance by the amount of the deposit" do
        Bot.fetch_new_transactions
        @user.reload
        @user.balance.should == @deposit_amount + @balance
      end
    end

    describe "from a new user" do
      it_should_behave_like "a generic deposit"
    end
  end

  describe "with multiple transactions in its journal" do
    before do
      @deposit_amount = 5300000
      @user_name = users(:roquezir).eve_character_name
      @user_id = users(:roquezir).eve_character_id
      @result = {
        "eveapi" => {
          "currentTime" => "2008-08-22 12:00:16",
          "result" => {
            "rowset" => {
              "row" => [
                {
                  "date" => "2008-08-21 00:12:00",
                  "refID" => "1575178039",
                  "refTypeID" => "64", 
                  "ownerName1" => @user_name,
                  "ownerID1" => @user_id,
                  "ownerName2" => "EvETrade Teller",
                  "ownerID2" => "43",
                  "amount" => @deposit_amount.to_s,
                  "balance" => "5300000.00"
                },
                {
                  "date" => "2008-08-21 00:12:02",
                  "refID" => "1575178039",
                  "refTypeID" => "64", 
                  "ownerName2" => @user_name,
                  "ownerID2" => @user_id,
                  "ownerName1" => "EvETrade Teller",
                  "ownerID1" => "42",
                  "amount" => 42,
                  "balance" => "100000000.00"
                }
              ]
            }
          },
          "cachedUntil" => "2008-08-22 12:15:16"
        }
      }
      Bot.stub!(:get).and_return(@result)
    end

    describe "containing one withdrawal" do
      it "should not create a Withdrawal because these are created when a user asks for one" do
        Bot.fetch_new_transactions
        Withdrawal.count.should == 0 
      end
    end

    describe "containing one deposit from a new user" do
      it_should_behave_like "a generic deposit"
    end

    describe "containing one deposit from an existing user" do
      before do
        @balance = 42
        @user = users(:roquezir)
      end

      it_should_behave_like "a generic deposit"
    end
  end

  describe "when the API will not provide us with the Wallet Journal because we asked for it within the past hour" do
    before do
      @result = { "eveapi" => { "error" => "You suck" } }
      Bot.stub!(:get).and_return(@result)
    end

    it "should not error out" do
      lambda { Bot.fetch_new_transactions }.should_not raise_error
    end
  end
end
