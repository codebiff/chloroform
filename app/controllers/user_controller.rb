class UserController < ApplicationController

  skip_before_filter :require_login, :except => ["account", "reset_verification", "settings", "save_settings"]

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
    reset_session
    flash[:info] = "You have successfully logged out"
    redirect_to root_path
  end

  def account
    @unread_messages = current_user.messages.select{|m| m.read == false}.reverse
  end

  def reset_verification
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
    @settings = current_user.config
  end

  def save_settings
    current_user.update_settings params
    flash[:info] = "Settings have been updated"
    redirect_current_user
  end

  def reset_api_key
    current_user.reset_api
    flash[:info] = "API Key reset"
    redirect_to account_path
  end

  def example
  end

  def admin
    admin?
    @users = User.all
  end

end
