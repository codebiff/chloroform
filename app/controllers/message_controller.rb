class MessageController < ApplicationController

  def index
    @messages = current_user.messages.reverse
  end

  def delete
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

  def delete_all
    current_user.messages = []
    current_user.save
    flash[:info] = "All messages deleted"
    redirect_to :back
  end

  def toggle_read 
    if params[:id]
      current_user.toggle_read(params[:id])
      redirect_to :back
    else
      flash[:error] = "Error with that message"
      redirect_to :back
    end
  end

  def toggle_all_read
    messages = current_user.messages.select{|m| m.read == false}
    messages.each {|m| m.read = true}
    current_user.save
    flash[:info] = "All messages marked as read"
    redirect_to :back
  end

end
