class PortfolioController < ApplicationController
  before_filter :login_required

  layout 'default'

  def index
    @stock_shares = current_user.shares.find_all_by_type(nil)
    @bond_shares = current_user.shares.find_all_by_type("BondShare")
    @sell_orders = current_user.sell_orders
    @buy_orders = current_user.buy_orders
    @buy_order = BuyOrder.new
    @sell_order = SellOrder.new
    @transactions = Transaction.find(:all, :conditions => ["payee_id = ? OR payer_id = ?", current_user, current_user], :order => "created_at DESC")
    @transactions.reject!{ |t| t.is_a?(FeePayout) && t.payee_id != current_user.id }
    @transactions.sort! do |t1, t2| 
      if t1.occurred_at && t2.occurred_at
        t1.occurred_at <=> t2.occurred_at
      elsif t1.occurred_at
        t1.occurred_at <=> t2.created_at
      elsif t2.occurred_at
        t1.created_at <=> t2.occurred_at
      else 
        t1.created_at <=> t2.created_at
      end
    end
    logger.debug(@transactions.inspect)
  end

  def funds_withdrawal
    amount = params["withdrawal"]["amount"].to_i
    total_pending_withdrawal = current_user.withdrawals.find_all_by_state("pending").inject(0) { |m, w| m += w.amount }
    if current_user.balance >= amount + total_pending_withdrawal
      formatted_amount = ActionView::Helpers::NumberHelper.number_with_delimiter amount, :delimiter => ','
      w = Withdrawal.create( :payee => current_user, :amount => amount, :state => "pending")
      if w.valid?
        flash[:notice] = "Your requests to withdraw #{formatted_amount} ISK has been submitted and
          will be serviced by a teller at the earliest opportunity"
      else
        flash[:error] = w.errors
      end
    else 
      formatted_amount = ActionView::Helpers::NumberHelper.number_with_delimiter amount, :delimiter => ','
      formatted_balance = ActionView::Helpers::NumberHelper.number_with_delimiter current_user.balance, :delimiter => ','
      flash[:error] = "We are sorry; however, your current balance of #{formatted_balance} ISK"
      if total_pending_withdrawal > 0
        flash[:error] << " less the pending withdrawals amounting #{total_pending_withdrawal}"
      end
      flash[:error] << " is less than the requested amount of #{formatted_amount} ISK"
    end
    redirect_to :action => "index"
  end
end
