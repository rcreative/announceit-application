class WelcomeController < ApplicationController
  def index
    redirect_to signup_url
  end
end