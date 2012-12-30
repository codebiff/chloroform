class UserController < ApplicationController

  def index
  end

  def login
    user = User.find_or_create params[:email], params[:password]
    if user.kind_of? User
      redirect_to user_account_path
    else
      redirect_to user_index_path
    end
  end

  def logout
    redirect_to user_index_path
  end

  def account
  end

end
