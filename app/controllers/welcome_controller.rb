class WelcomeController < ApplicationController
  layout "public"
  
  def index
    redirect_to admin_settings_path if logged_in?
  end
end