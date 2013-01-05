module ApplicationHelper

  def title page_title
    content_for :title, page_title.to_s
  end

  def read_status message
    message.read ? "warning" : "info"    
  end

end
