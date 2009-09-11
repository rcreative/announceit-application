class TeasersController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  before_filter :assign_account
  before_filter :assign_teaser
  before_filter :track_visitor, :unless => :logged_in?
  
  def show
    subscriber = Subscriber.find(params[:subscriber_id]) rescue Subscriber.new
    subscriber.name = subscriber.email = ''
    render :text => @teaser.template.render(:subscriber => subscriber, :teaser => @teaser), :content_type => 'text/html'
  end
  
  def subscribe
    @subscriber = @teaser.subscribers.create(params[:subscriber])
    if @subscriber.new_record?
      render :text => @teaser.template.render(:subscriber => @subscriber, :teaser => @teaser), :content_type => 'text/html'
    else
      @teaser.subscribes.create!(
        :subscriber => @subscriber,
        :visitor => @visitor,
        :subscribed_on => Date.today
      )
      redirect_to teaser_view_url(@account, @subscriber)
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
        redirect_to Rails.configuration.announce.application_teaser_url
      end
    end
    
    # It is important to understand the reason we do not specify the cookie
    # :domain as *.annouceitapp.com, etc. According to
    # http://en.wikipedia.org/wiki/HTTP_cookie, browsers typically limit the
    # number of cookies per domain that they will store (LCD of 20). Without
    # actual testing, I did not want to bump into this. Therefore, we will be
    # storing by FQDN; myteaser.announceitapp.com has cookies separate from
    # yourteaser.announceitapp.com.
    #
    def track_visitor
      visitor_cookie_name = "teaser.#{@teaser.id}.visitor"
      if cookies[visitor_cookie_name].blank? || (@visitor = @teaser.visitors.find_by_cookie(cookies[visitor_cookie_name])).nil?
        @visitor = @teaser.visitors.create!
        install_persistent_cookie(visitor_cookie_name, @visitor.cookie)
      end
      
      if recent_visit = @visitor.visits.last(:conditions => ['visited_at > ?', 1.hour.ago])
        recent_visit.update_attribute(:visited_at, Time.now)
      else
        @visitor.visits.create!
      end
    end
    
    # Not setting :expires of cookie makes it a session cookie. Those are
    # deleted from the browser when it is restarted.
    #
    def install_persistent_cookie(name, cookie)
      cookies[name] = {
        :value => cookie,
        :expires => 10.years.from_now
      }
    end
end