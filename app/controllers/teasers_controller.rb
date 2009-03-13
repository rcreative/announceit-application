class TeasersController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  before_filter :assign_account
  before_filter :assign_teaser
  before_filter :track_visitor
  
  def show
    render_teaser_page
  end
  
  def subscribe
    @subscriber = @teaser.subscribers.create(params[:subscriber])
    if @subscriber.new_record?
      render_teaser_page
    else
      flash[:thanks] = true
      redirect_to teaser_view_url(@account)
    end
  end
  
  private
    def assign_account
      @account = current_account || begin
        if Rails.configuration.announce.tlds.include?(request.domain)
          Account.find_by_subdomain(request.subdomains.first)
        else
          Account.find_by_custom_domain(request.host)
        end
      end
      
      if @account.nil?
        redirect_to (Rails.env.production? ? "http://www.announceitapp.com" : root_url)
      end
    end
    
    def render_teaser_page
      render :template => "teasers/#{@teaser.template_name}.html.haml", :layout => false
    end
    
    def track_visitor
      visitor_cookie_name = "teaser.#{@teaser.id}.visitor"
      if cookies[visitor_cookie_name].blank?
        @visitor = @teaser.visitors.create!
        cookies[visitor_cookie_name] = @visitor.cookie
      else
        @visitor = @teaser.visitors.find_by_cookie(cookies[visitor_cookie_name])
      end
      @visitor.visits.create!(:visited_at => Time.now)
    end
end