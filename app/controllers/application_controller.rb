class ApplicationController < ActionController::Base
  protect_from_forgery

  def authorize!
    if session[:user]
      return true
    else
      redirect_to user_index_path
    end
  end

end
