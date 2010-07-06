class Article < ActiveRecord::Base
  belongs_to :stock
  belongs_to :user

  validates_presence_of :headline, :body, :state

  named_scope :featured,
    :order => "updated_at DESC", 
    :conditions => ["state != ? and frontpage = ?", "denied", true],
    :limit => 15

  named_scope :non_featured,
    :order => "updated_at DESC", 
    :conditions => ["state != ? and frontpage = ?", "denied", false],
    :limit => 20

  named_scope :most_recent_approved, 
    :limit => 10, 
    :order => "created_at DESC", 
    :conditions => ["state = ?", "approved"]

  named_scope :approved,
    :order => "created_at DESC", 
    :conditions => ["state = ?", "approved"]

  named_scope :pending, 
    :order => "created_at DESC", 
    :conditions => ["state = ?", "pending"]

  def before_validation_on_create
    unless self.state == "pending"
      errors.add(:state, "must be pending at creaton time")
    end
    if self.frontpage && !user.bill_for_featured_article
      errors.add(:user, "You do not have the necessary funds to publish a featured article")
    end
  end

  def validate
    unless ["pending", "approved", "denied"].include? self.state
      errors.add(:state, "State must be pending, active, or denied")
    end
    if user.id != stock.ceo.id
      errors.add(:stock, "You cannot publish official news about a product that you do not own")
    end
  end

  def body_with_ellipsis_at(position)
    body = body_from_markdown
    if body_from_markdown.length > position
      next_whitespace_at = self.body.index(" ", position)
      BlueCloth.new(self.body[0...next_whitespace_at] + " ...").to_html
    else
      body_from_markdown
    end
  end

  def body_from_markdown
    BlueCloth.new(body).to_html
  end
end
