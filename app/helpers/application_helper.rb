module ApplicationHelper

  def current_user
    @current_user ||= User.first(:id => session[:user]) if session[:user]
  end


end
