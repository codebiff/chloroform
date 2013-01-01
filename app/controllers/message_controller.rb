class MessageController < ApplicationController

  def delete
    if params[:id]
      current_user.messages.delete_if{|m| m.id.to_s == params[:id]}
      current_user.save
      redirect_to account_path
    else
      flash[:error] = "Error deleting message"
      redirect_to account_path
    end
  end

end
