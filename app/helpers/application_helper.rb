module ApplicationHelper
  def application_name
    "Announce It"
  end
  
  def application_domain
    request.domain
  end
  
  def application_host_with_port
    domain = "#{request.domain}"
    port = request.port
    domain += ":#{port}" if port != 80
    domain
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
  
  # Returns a Gravatar URL associated with the email parameter.
  # See: http://douglasfshearer.com/blog/gravatar-for-ruby-and-ruby-on-rails
  def gravatar_url(email, gravatar_options={})
    # Default highest rating.
    # Rating can be one of G, PG, R X.
    # If set to nil, the Gravatar default of G will be used.
    gravatar_options[:rating] ||= "G"
    
    # Default size of the image.
    # If set to nil, the Gravatar default size of 32px will be used.
    gravatar_options[:size] ||= "32px"
    
    # Default image url to be used when no gravatar is found
    # or when an image exceeds the rating parameter.
    gravatar_options[:default] ||= "#{request.protocol}#{request.host_with_port}/images/avatar_32x32.png"
    
    # Build the Gravatar url.
    grav_url = 'http://www.gravatar.com/avatar.php?'
    grav_url << "gravatar_id=#{Digest::MD5.new.update(email)}" 
    grav_url << "&rating=#{gravatar_options[:rating]}" if gravatar_options[:rating]
    grav_url << "&size=#{gravatar_options[:size]}" if gravatar_options[:size]
    grav_url << "&default=#{gravatar_options[:default]}" if gravatar_options[:default]
    return grav_url
  end
  
  def name_and_email(name, email)
    email = %{<span class="email">#{mail_to h(email)}</span>}
    if name.blank?
      email
    else
      %{<span class="name">#{h name}</span> (#{email})}
    end
  end
  
  def teaser_view_url(account, subscriber = nil)
    subscriber_id = subscriber ? subscriber.id : nil
    if Rails.env.production?
      url_for :host => teaser_host(account), :controller => '/teasers', :action => 'show', :subscriber_id => subscriber_id
    else
      teaser_url :subscriber_id => subscriber_id
    end
  end
  
  def teaser_host(account)
    account.domain_type == 'subdomain' ? "#{account.subdomain}.#{application_host_with_port}" : account.custom_domain
  end
end
