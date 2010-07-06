class OrderFee < Fee
  belongs_to :stock
  validates_presence_of :stock_id
end
