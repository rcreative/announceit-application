module ApplicationHelper
  def application_domain
    request.host_with_port
  end
  
  # Calculate the appropriate years for copyright
  def copyright_years
    start_year = 2009
    end_year = Date.today.year
    if start_year == end_year
      "#{start_year}"
    else
      "#{start_year}&#8211;#{end_year}"
    end
  end
  
  def errors_on?(*objects)
    objects.any? do |object|
      object = instance_variable_get("@#{object}") if object.kind_of?(Symbol)
      (!object.nil?) && (object.errors.count > 0)
    end
  end
  
  def teaser_host(account)
    "#{account.subdomain}.#{application_domain}"
  end
  
  def teaser_view_url(account)
    if Rails.env.production?
      url_for :host => teaser_host(account), :controller => '/teasers', :action => 'show'
    else
      url_for '/teaser'
    end
  end
end
