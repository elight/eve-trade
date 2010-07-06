class Deposit < Transaction
  belongs_to :payer, :class_name => "User"

  validates_presence_of :amount, :occurred_at, :ref_id, :payer_eve_id, :payer_name
  validates_numericality_of :amount
  validates_numericality_of :ref_id

  def validate
    unless payer || payer_name
      errors.add(:payer_id, "Must have a sender ID or sender Name")
    end
  end

  def self.create_from(hash)
    begin
      sender = User.find_by_eve_character_id(hash["ownerID1"])

      t = Deposit.create!(
        :payer_name => hash["ownerName1"],
        :payer_id => sender,
        :payer_eve_id => hash["ownerID1"],
        :amount => hash["amount"],
        :ref_id => hash["refID"],
        :occurred_at => DateTime.parse(hash["date"])
      )
      sender.update_attribute(:balance, sender.balance + t.amount)
      sender.reload

      t
    rescue Exception => e
      logger.error(e.message)
      e.backtrace.each { |l| Stock.logger.error(l.to_s) }
    end
  end
end
