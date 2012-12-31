class UserController < ApplicationController

  def index
  end

  def login
    user = User.find_or_create params[:email], params[:password]
    if user.kind_of? User
      session[:user] = user.id.to_s
      redirect_to account_path
    else
      flash[:error] = user
      redirect_to root_path
    end
  end

  def logout
    session.clear
    flash[:info] = "You have successfully logged out"
    redirect_to root_path
  end

  def account
    authorize!
  end

end
