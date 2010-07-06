class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
  
    user.reload
    @body[:url]  = "#{PROTOCOL}://#{SITE}/activate/#{user.activation_code}"
  
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "#{PROTOCOL}://#{SITE}/"
  end

  def forgot_password(user)
    setup_email(user)
    @subject    += 'You have requested to change your password'
    @body[:url]  = "#{PROTOCOL}://#{SITE}/reset_password/#{user.password_reset_code}"
  end

  def reset_password(user)
    setup_email(user)
    @subject    += 'Your password has been reset.'
  end

  def notify_ceo_of_failed_repayment(bond_share)
    setup_email(bond_share.stock.ceo)
    @subject    += "Failed automated repayment of bond #{bond_share.stock.symbol}"
    @bond_holder = bond_share.user.eve_character_name
    @num_shares = bond_share.number
    @balance = bond_share.stock.ceo.balance
    @bond_symbol = bond_share.stock.symbol
    @shares_bought_at = bond_share.created_at
    @bonds_matured_at = (@shares_bought_at + bond_share.stock.months_until_maturity.months + 1.day).beginning_of_day
    @bond_value = bond_share.market_value
  end

  def notify_holder_of_failed_repayment(bond_share)
    setup_email(bond_share.stock.ceo)
    @subject    += "Failed automated repayment of bond #{bond_share.stock.symbol}"
    @num_shares = bond_share.number
    @bond_symbol = bond_share.stock.symbol
    @bond_ceo = bond_share.stock.ceo.eve_character_name
    @shares_bought_at = bond_share.created_at
    @bonds_matured_at = (@shares_bought_at + bond_share.stock.months_until_maturity.months + 1.day).beginning_of_day
  end

  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "EVE-Trade Bot"
      @subject     = "[EVE-Trade] "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
