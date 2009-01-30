class TeasersController < ApplicationController
  before_filter :assign_account
  before_filter :assign_teaser
  
  def subscribe
    @subscriber = @teaser.subscribers.create(params[:subscriber])
    if @subscriber.new_record?
      render :action => :show
    else
      flash[:notice] = 'Thank you!'
      redirect_to teaser_view_url(@account)
    end
  end
  
  private
    def assign_account
      @account = current_account || Account.find_by_subdomain(request.subdomains.first)
      head :not_found unless @account
    end
end