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
    session[:user] = nil
    flash[:info] = "You have successfully logged out"
    redirect_to root_path
  end

  def account
    authorize!
    @unread_messages = current_user.messages.select{|m| m.read == false}.reverse
  end

  def reset_verification
    authorize!
    current_user.reset_verification
    flash[:info] = "A new verification email has been sent"
    redirect_to account_path
  end

  def verify
    if User.verify params[:token]
      flash[:info] = "Thank you for verifying your email address"
      redirect_current_user
    else
      flash[:error] = "There was a problem with your verification token"
      redirect_current_user
    end
  end

  def settings
    authorize! 
    @settings = current_user.config
  end

  def save_settings
    authorize!
    current_user.update_settings params
    flash[:info] = "Settings have been updated"
    redirect_current_user
  end

end
