class ApplicationController < ActionController::Base
  protect_from_forgery

  def authorize!
    if session[:user]
      return true
    else
      flash[:error] = "Please login or register to view that page"
      page root_path
    end
  end

end
