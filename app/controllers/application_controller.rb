class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user

  before_filter :require_login
  
  def require_login
    redirect_to root_url unless current_user
  end

  def current_user
    @current_user ||= User.first(:id => session[:user]) if session[:user]
  end

  def redirect_current_user
    if current_user
      redirect_to account_path
    else
      redirect_to root_path
    end
  end

end
