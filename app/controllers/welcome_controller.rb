class WelcomeController < ApplicationController
  layout "public"
  
  def index
    debugger
    redirect_to signup_url
  end
end