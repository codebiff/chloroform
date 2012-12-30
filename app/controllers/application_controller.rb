class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_user
    @current_user ||= User.first(:id => session[:user]) if session[:user]
  end

  def authorize!
    if session[:user]
      return true
    else
      redirect_to user_index_path
    end
  end

end
