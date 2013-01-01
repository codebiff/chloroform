class ApiController < ApplicationController

  def submit
    if user = User.find_by_api_key(params[:api_key])
      if user.submit(params, request.env['HTTP_REFERER'])
        render :json => "Success"
      else
        render :json => "No field data", :status => 400
      end
    else
      render :json => "Unknown API key", :status => 401
    end
  end

end
