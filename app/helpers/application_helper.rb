# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def application_domain
    "announceitapp.com"
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
  
  def teaser_url
    if Rails.env.production?
      raise "implement me"
    else
      teaser_dev_path
    end
  end
  
  def root_url
    "/"
  end
  
end
