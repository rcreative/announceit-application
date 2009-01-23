class TeasersController < ApplicationController
  before_filter :assign_account
  before_filter :assign_teaser
  
  def subscribe
    @subscriber = @teaser.subscribers.create(params[:subscriber])
    if @subscriber.new_record?
      render :action => :show
    else
      flash[:notice] = 'Thank you!'
      redirect_to :action => :show
    end
  end
  
  private
    def assign_account
      @account = current_account || Account.find_by_subdomain(request.subdomains.first)
    end
end