class WelcomeController < ApplicationController
  layout "public"
  
  def index
    case
    when logged_in?
      redirect_to admin_settings_path
    when Rails.env.production? && (request.host_with_port !~ %r{^www\.})
      redirect_to "http://www.#{request.host_with_port}"
    end
  end
end