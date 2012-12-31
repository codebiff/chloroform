class UserController < ApplicationController

  def index
    redirect_to account_path if current_user
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

  def reset_verification
    authorize!
    current_user.reset_verification
    flash[:info] = "A new verification email has been sent"
    redirect_to account_path
  end

end
