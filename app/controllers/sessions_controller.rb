# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  layout 'default'
  
  # render new.rhtml
  def new
  end

  def create
    logout_keeping_session!
    user = User.authenticate(params[:login], params[:password])
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"
    elsif deposit = Deposit.find_by_payer_name_and_amount(params[:login], params[:password])
      # Is this a user using a temporary login and password?
      if User.find_by_eve_character_name(params[:login])
        flash[:error] = "#{params[:login]} has already registered an EVE-Trade account!"
        logger.warn "Possible intrusion attempt, attempting to create an EVE-Trade account for a user who is already registered, by #{request.inspect}"
        redirect_to :action => "new"
        return
      end
      flash[:notice] = "Temporary password recognized.  Now create your EVE-Trade account."
      session[:deposit] = deposit
      redirect_to :controller => "users", :action => "new"
    else
      note_failed_signin
      @login       = params[:login]
      @remember_me = params[:remember_me]
      render :action => 'new'
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
