class Bot
  include HTTParty

  def self.fetch_new_transactions
    raw_transactions = wallet_journal(BOT_API_KEY, BOT_USER_ID, BOT_CHARACTER_ID)
    ActiveRecord::Base.logger.debug("result from wallet_journal: #{raw_transactions.inspect}")
    tansactions = raw_transactions.collect do |raw_transaction|
      ActiveRecord::Base.logger.debug("TRANSACTION: #{raw_transaction.inspect}")
      occurred_at = DateTime.parse(raw_transaction["date"])
      next if raw_transaction["ownerName1"] == BOT_NAME
      transaction_exists_in_records = Deposit.find_by_payer_name_and_occurred_at(
        raw_transaction["ownerName1"], 
        occurred_at
      )
      unless transaction_exists_in_records
        ActiveRecord::Base.logger.debug("CREATING TRANSACTION for #{raw_transaction.inspect}")
        Deposit.create_from raw_transaction
      end
    end
  end

  def self.wallet_journal(api, user, character)
    response = get("http://api.eve-online.com/char/WalletJournal.xml.aspx?apikey=#{api}&userid=#{user}&characterid=#{character}")
    ActiveRecord::Base.logger.debug("result from HTTParty get: #{response.inspect}")
    if response["eveapi"]["result"]
      if response["eveapi"]["result"]["rowset"]["row"].is_a? Hash
        [response["eveapi"]["result"]["rowset"]["row"]]
      else
        response["eveapi"]["result"]["rowset"]["row"]
      end
    elsif response["eveapi"]["error"]
      ActiveRecord::Base.logger.warn response["eveapi"]["error"]
      []
    end
  end

  def self.warn_bond_managers_of_repayment_of_mature_shares_in_1_week
    Bond.warn_bond_managers_of_repayment_due_in(:number => 1, :unit => :week)
  end

  def self.warn_bond_managers_of_repayment_of_mature_shares_in_1_month
    Bond.warn_bond_managers_of_repayment_due_in(:number => 1, :unit => :month)
  end

  def self.repay_mature_shares
    Bond.mature_shares.each do |bond_share|
      Bond.repay(bond_share)
    end
  end

  def self.pay_bond_interest
    BondShare.find(:all, :conditions => ["created_at <= ?", 1.month.ago + 1.day]).each do |bond_share|
      time_since_purchase = Time.now.to_i - bond_share.created_at.to_i
      Array(1..bond_share.stock.months_until_maturity).each do |num_months|
        if bond_share.created_at >= num_months.months.ago && bond_share.created_at <= num_months.months.ago + 1.day
          Bond.pay_interest_on(bond_share, num_months)
        end
      end
    end
  end

  private 

  def self.warn_bond_managers_of_repayment_due_in(params = {})
    Bond.shares_that_will_mature_in(params[:number].send(params[:unit])).each do |bond_shares|
      UserMailer.warn_bond_manager_of_repayment_of(share, :in => params[:number], :unit => params[:unit])
    end
  end
end
