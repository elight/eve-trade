# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.



class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :force_ssl

  include AuthenticatedSystem

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  #
  def admin_required
    current_user.is_admin? || access_denied
  end

  def force_ssl
    redirect_to :protocol => "https://", :port => 443 unless (request.ssl? or local_request?)
  end
end
