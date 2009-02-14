class WelcomeController < ApplicationController
  layout "public"
  
  def index
    if logged_in?
      redirect_to admin_settings_path
    elsif Rails.env.production? && (request.host_with_port !~ %r{^www\.})
      redirect_to "http://www.#{request.host_with_port}"
    end
  end
end