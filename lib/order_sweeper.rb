module OrderSweeper
  def self.execute
    expired_orders = Order.find(:all, :conditions => ["expires_at <= ?", Time.now.utc])
    expired_orders.each { |o| o.destroy }
  end
end
