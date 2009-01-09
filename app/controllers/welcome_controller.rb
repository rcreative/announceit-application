class WelcomeController < ApplicationController
  layout "public"
  
  def index
    redirect_to signup_url
  end
end