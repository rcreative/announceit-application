# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ExceptionNotifiable
  include AuthenticatedSystem
  
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '84e861c700ba863b52728ccb7a849712'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  filter_parameter_logging :password, :password_confirmation
  
  protected
    def application_name
      "Announce It"
    end
    helper_method :application_name
    
    def application_domain
      request.host_with_port
    end
    helper_method :application_domain
    
    def teaser_view_url(account)
      if Rails.env.production?
        url_for :host => teaser_host(account), :controller => '/teasers', :action => 'show'
      else
        url_for '/teaser'
      end
    end
    helper_method :teaser_view_url
    
    def teaser_host(account)
      "#{account.subdomain}.#{application_domain}"
    end
    helper_method :teaser_host
    
  private
    def assign_teaser
      @teaser = @account.teaser
    end
end
