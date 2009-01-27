class AccountsController < ApplicationController
  CREATE_KEY = 'dk3su29sw'
  
  layout "public"
  
  before_filter :check_key
  
  def create
    logout_keeping_session!
    @account = Account.new(params[:account])
    success = @account && @account.save
    if success && @account.errors.empty?
      # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session
      self.current_account = @account # !! now logged in
      redirect_back_or_default('/settings')
      flash[:notice] = "Thanks for signing up!"
    else
      flash[:error]  = "We couldn't set up that account, sorry."
      render :action => 'new'
    end
  end
  
  private
    def check_key
      redirect_to root_url unless params[:key] == CREATE_KEY
    end
end