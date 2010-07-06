namespace :eve_trade do
  desc "Repay mature bonds for today" 
  task :repay_mature_bonds => [:environment] do
    Bot.repay_mature_shares
  end

  desc "Pay monthly bond interest for today"
  task :pay_monthly_bond_interest => [:environment] do
    Bot.pay_bond_interest
  end
  
  desc "Remove orders that have lived past their expiration date"
  task :order_sweep => [:environment] do
    OrderSweeper.execute
  end

  desc "Poll the teller's wallet for deposits"
  task :poll_teller_wallet => [:environment] do
    Bot.fetch_new_transactions
  end
end
