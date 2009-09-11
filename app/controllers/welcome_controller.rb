class WelcomeController < ApplicationController
  layout "public"
  
  def index
    if logged_in?
      redirect_to admin_dashboard_path
    elsif display_application_teaser?
      redirect_to Rails.configuration.announce.application_teaser_url
    end
  end
  
  private
    def display_application_teaser?
      Rails.env.production? && (request.host_with_port !~ %r{^www\.})
    end
end