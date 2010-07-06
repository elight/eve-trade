class StocksController < ApplicationController
  before_filter :login_required

  layout 'default'

  def show_mgmt
    @stock = InternalStock.new
    @bond = Bond.new
  end

  def disburse_dividend
    stock = Stock.find params[:stock_id]
    return if caller_does_not_manage stock
    div = stock.current_dividend
    unless div
      render :json => {:error => "Sorry but you need to set a dividend before disbursing one"}
      return
    end
    begin
      stock.pay_dividends!
      render :json => {:ok => "Dividends paid"}
    rescue Exception => e
      render :json => {:error => e.message}
      logger.error(e.message)
      e.backtrace.each { |l| logger.error(l.to_s) }
    end
  end


  def set_dividend
    stock = Stock.find params[:stock_id]
    return if caller_does_not_manage stock
    Dividend.create!(:amount => params[:dividend], :stock_id => params[:stock_id])
    render :json => {:ok => "Dividend set to #{params[:dividend]}"}, :status => :ok
  end

  def show
    @stock = Stock.find params[:id]
    last_trade = @stock.last_trade
    @last_trade_cost_per_share = last_trade ? last_trade.price_per_share : 0
    @last_trade_time =  @stock.last_trade ? @stock.last_trade.created_at : nil
    @market_cap = @stock.market_cap
    @daily_volume = @stock.daily_volume
    @ask = @stock.current_ask
    @bid = @stock.current_bid
    @days_min, @days_max = @stock.todays_range
    @avg_volume = @stock.average_volume_3_months
    sell_orders = @stock.sell_orders
    @sell_orders_other_than_mine = sell_orders.find(:all, :conditions => ["user_id != ?", current_user.id])
    @trades = @stock.purchases.ordered_by_created_at
    @max_trade = @stock.purchases.ordered_by_price_per_share.first
    @featured_articles = @stock.articles.featured
    @other_articles = @stock.articles.non_featured
    @buy_order = BuyOrder.new(:total_shares => 1, :price_per_share => @last_trade_cost_per_share, :expires_at => 3.months.from_now.to_date)
    @sell_order = SellOrder.new(:total_shares => 1, :price_per_share => @last_trade_cost_per_share, :expires_at => 3.months.from_now.to_date)
  end

  def add_stock
    new_stock_args = params["stock"]
    new_stock_args["ceo_id"] = current_user.id
    logger.debug new_stock_args.inspect
    stock = InternalStock.create(new_stock_args)
    if stock.valid?
      flash[:notice] = "#{stock.name} (#{stock.symbol}) is now available for public trading"
      redirect_to corporate_management_path
    else
      flash[:error] = stock.errors
      redirect_to corporate_management_path
    end
  end

  def add_bond
    bond_args = params["bond"]
    bond_args.merge!(
      "ceo_id" => current_user.id
    )
    logger.debug bond_args.inspect
    bond = Bond.create(bond_args)
    if bond.valid?
      flash[:notice] = "#{bond.name} (#{bond.symbol}) is now available for public trading"
      redirect_to corporate_management_path
    else
      flash[:error] = bond.errors
      redirect_to corporate_management_path
    end
  end

  def search
    @query = params[:search]
    logger.debug "Searchingfor '#{@query}'"
    @results = Stock.search params[:search]
    logger.debug "Found #{@results.inspect}"
    if @results.size == 1
      redirect_to :action => :show, :id => @results.first.id
    end
  end

  def cancel_sell_order 
    sell_order = current_user.sell_orders.find(params['id'])
    if sell_order
      sell_order.destroy
      render :json => {}
    else
      render :json => {:error => "Could not locate order ID " + params['id'].to_s}
    end
  end

  def cancel_buy_order 
    buy_order = current_user.buy_orders.find(params['id'])
    if buy_order
      buy_order.destroy
      render :json => {}
    else
      render :json => {:error => "Could not locate order ID " + params['id'].to_s}
    end
  end

  def place_sell_order
    sell_order = current_user.sell_orders.create(params["sell_order"])
    if !sell_order.errors.empty?
      logger.debug sell_order.errors.inspect
      flash[:error] = sell_order.errors
    else
      units_sold = sell_order.broker_trade!
      if units_sold > 0
        flash[:notice] = "Brokered trade for #{units_sold} shares of #{sell_order.stock.symbol}"
        if sell_order.complete?
          flash[:notice] << "<br/>Sell order completed for requested #{sell_order.total_shares} shares."
        else
          flash[:notice] << "<br/>This sell order will remain open until either #{sell_order.remaining_shares} are sold or the expiration date of #{sell_order.expires_at}."
        end
      else
        flash[:notice] = "Sell order opened."
      end
    end
    redirect_to :controller => :portfolio, :actions => :index
  end

  def place_buy_order
    buy_order = current_user.buy_orders.create(params["buy_order"])
    if !buy_order.errors.empty?
      logger.debug buy_order.errors.inspect
      flash[:error] = buy_order.errors
    else
      units_purchased = buy_order.broker_trade!
      if units_purchased > 0
        flash[:notice] = "Brokered trade for #{units_purchased} shares of #{buy_order.stock.symbol}"
        if buy_order.complete?
          flash[:notice] << "<br/>Buy order completed for requested #{buy_order.total_shares} shares."
        else
          flash[:notice] << "<br/>This buy order will remain open until either #{buy_order.remaining_shares} are purchased or the expiration date of #{buy_order.expires_at}."
        end
      else
        flash[:notice] = "Buy order opened."
      end
    end
    redirect_to :controller => :portfolio, :actions => :index
  end

  def bond_customers
    @stock = Stock.find(params[:id])
    if current_user != @stock.ceo
      render :nothing => true
    else
      render :partial => "select_customer_to_refund_dialog"
    end
  end

  def process_bond_refund
    share_ids = params.keys.select { |k| k =~ /share_(\d+)/ }
    share_ids.each do |share_id|
      share = BondShare.find(params[share_id])
      next unless share.stock.ceo.id == current_user.id
      Bond.refund(share)
    end
    flash[:notice] = "Refunded selected shares"
    redirect_to corporate_management_path
  end

  def is_user_balance_adequate_to_create_stock_or_bon
    render :json => current_user.balance >= Fee::INITIAL_SELL_ORDER_FEE
  end

  def request_audit
    stock = Stock.find(params[:stock_id])
    AuditRequest.create!(
      :payer_id => current_user.id,
      :stock_id => stock.id,
      :amount => Fee::AUDIT_FEE
    )
    flash[:notice] = "Your audit request for #{stock.symbol} is now pending"
    redirect_to "/corp_mgmt"
  end

  private
   
  def handle_naughty_boy
    flash["error"] = "You selected an illegal stock type. Are you trying to hack the system?"
    alert = "#{current_user.eve_character_name} supplied an illegal stock type, '#{params["stocks"]["stock_type"]}', when creating a stock. This could be a hack attempt!"
    logger.warn alert
    redirect_to corporate_management_path
  end

  def caller_does_not_manage(stock)
    unless stock
      render :json => {:error => "Sorry but stock #{params[:stock_id]} does not exist"}, :status => :ok
      true
    end
    unless stock.ceo_id == current_user.id
      render :json => {:error => "Sorry but you don't own that stock"}, :status => :ok
      true
    end
    false
  end
end
