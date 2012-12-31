module ApplicationHelper

  def current_user
    @current_user ||= User.first(:id => session[:user]) if session[:user]
  end

  def title page_title
    content_for :title, page_title.to_s
  end

end
