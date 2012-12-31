class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user

  before_filter :set_mailer_host
  def set_mailer_host
    @request_host = request.host_with_port
  end

  def authorize!
    if session[:user]
      return true
    else
      flash[:error] = "Please login or register to view that page"
      redirect_to root_path
    end
  end

  def current_user
    @current_user ||= User.first(:id => session[:user]) if session[:user]
  end

end
