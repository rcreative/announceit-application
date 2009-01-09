# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def application_domain
    "announceit.com"
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
  
end
