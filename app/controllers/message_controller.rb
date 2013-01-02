class MessageController < ApplicationController

  def index
    authorize!
    @messages = current_user.messages.reverse
  end

  def delete
    authorize!
    if params[:id]
      current_user.messages.delete_if{|m| m.id.to_s == params[:id]}
      current_user.save
      flash[:info] = "Message deleted"
      redirect_to :back
    else
      flash[:error] = "Error deleting message"
      redirect_to :back
    end
  end

  def toggle_read 
    authorize!
    if params[:id]
      current_user.toggle_read(params[:id])
      redirect_to account_path
    else
      flash[:error] = "Error with that message"
      redirect_to account_path
    end
  end

  def toggle_all_read
    authorize!
    messages = current_user.messages.select{|m| m.read == false}
    messages.each {|m| m.read = true}
    current_user.save
    flash[:info] = "All messages marked as read"
    redirect_to :back
  end

end
