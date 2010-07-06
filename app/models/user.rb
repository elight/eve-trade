require 'digest/sha1'

class User < ActiveRecord::Base
  has_many :managed_corporations, :class_name => "Stock", :foreign_key => "ceo_id"
  has_many :bonds, :foreign_key => :ceo_id
  has_many :shares
  has_many :deposits , :foreign_key => :payer_id
  has_many :withdrawals, :foreign_key => :payee_id
  has_many :buys, :class_name => "Purchase", :foreign_key => :payer_id
  has_many :sales, :class_name => "Purchase", :foreign_key => :payee_id
  has_many :buy_orders
  has_many :sell_orders
  has_many :articles
  has_many :fees, :foreign_key => :payer_id

  has_many :audit_requests, :foreign_key => :payer_id

  attr_accessible :eve_character_id, :eve_character_name

  include HTTParty
  format :xml

  validates_presence_of :login, :eve_character_id
  validates_uniqueness_of :login, :eve_character_id, :eve_character_name

  def validate
    if balance < 0
      errors.add(:balance, "may not be less than 0 ISK")
    end
  end

  def bill_for_featured_article
    if balance >= Fee::FEATURED_ARTICLE
      fee = ArticleFee.new(:amount => Fee::FEATURED_ARTICLE, :payer_id => self.id)
      if fee.save
        return true
      end
    end
    false
  end

  def after_create
    transaction do 
      d = Deposit.find_by_payer_name(self.eve_character_name)
      if d.nil?
        logger.error("Could not find the deposit matching this new user")
        return
      end
      d.payee_id = self.id
      self.balance += d.amount
      d.save!
      self.save!
    end
  end

  def has_unallocated_shares_in?(stock)
    my_shares = self.shares.find_all_by_stock_id(stock.id)
    my_shares.each { |s| return true if s.number_for_sale < s.number }
    false
  end

  ####### hacked on forgotten password #######

  def forgot_password
    @forgotten_password = true
    self.make_password_reset_code
  end

  def reset_password
    # First update the password_reset_code before setting the 
    # reset_password flag to avoid duplicate email notifications.
    update_attributes(:password_reset_code => nil)
    @reset_password = true
  end  

  #used in user_observer
  def recently_forgot_password?
    @forgotten_password
  end
  
  def recently_reset_password?
    @reset_password
  end
  
  def recently_activated?
    @recent_active
  end

  ######## Restful Authentication ########

  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::StatefulRoles

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message


  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation



  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_in_state :first, :active, :conditions => {:login => login.downcase} # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  protected


    def make_password_reset_code
      self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end
    
    def make_activation_code
        self.deleted_at = nil
        self.activation_code = self.class.make_token
    end


end
