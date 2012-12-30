class UserController < ApplicationController

  def index
  end

  def login
    user = User.find_or_create params[:email], params[:password]
    redirect_to user_account_path
  end

  def logout
  end

  def account
  end

end
