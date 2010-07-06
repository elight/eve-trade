require File.join(File.dirname(__FILE__), "..", "test_helper")


class NormalUserCorpMgmtTest < ActionController::IntegrationTest
  fixtures :users

  context "A logged in CEO user" do
    setup do 
      # 50M per stock
      # 100M for audit
      # 10M extra
      login_user :ceo_user, :balance => 210_000_000
    end

    context "managing one stock and one bond" do
      setup do
        @stock = Factory(:stock, :ceo => @user)
        @bond = Factory(:bond, :ceo => @user)
        @user.reload
        raise Exception.new unless @user.balance == 110_000_000
      end

      context "when on the corporate management page" do
        setup do
          @products = [@stock, @bond]
          @stock_managed_by_someone_else = Factory(:stock)
          get "/corp_mgmt"
        end

        should "see a list containing his products" do
          @products.each do |stock|
            assert_match(/#{stock.symbol}/, response.body)
          end
        end

        should "not see someone else's products" do
          assert(response.body !~ /#{@stock_managed_by_someone_else.symbol}/)
        end

        context "who has enough money for an audit" do 
          should "see a button to request an audit" do
            assert_select "button.request_audit", :text => "Request Audit", :count => @products.size
          end

          context "who has clicked a 'request audit' button" do
            setup do
              @user.reload
              @balance_before = @user.balance
              post "/stocks/request_audit", { :stock_id => @stock.id }
              @user.reload
            end

            should "be billed for the audit" do
              assert_equal(Fee::AUDIT_FEE, @balance_before - @user.balance)
            end

            should "have a transaction requesting an audit" do
              assert(@user.audit_requests.first)
            end

            should "have an audit request for the specified product" do
              assert_equal(@stock, @user.audit_requests.first.stock)
            end

            should "be redirected to the corporate management page" do
              assert_redirected_to("/corp_mgmt")
            end

            should "be flashed a message telling them that there audit is pending" do
              assert_match(/audit.*request.*pending/, flash[:notice])
            end
          end
        end
      end
    end
  end
end

