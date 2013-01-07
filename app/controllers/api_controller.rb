class ApiController < ApplicationController

  skip_before_filter :require_login

  def submit
    if user = User.find_by_api_key(params[:api_key])
      if message = user.submit(params, request.env['HTTP_REFERER'])
        if ! message.confirm_url.nil?
          redirect_to message.confirm_url 
        else
          render :text => "Thank you."
        end
      else
        render :json => "No field data", :status => 400
      end
    else
      render :json => "Unknown API key", :status => 401
    end
  end

end
