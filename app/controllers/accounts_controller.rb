class AccountsController < ApplicationController
  CREATE_KEY = 'dk3su29sw'
  
  before_filter :check_key, :except => [:edit, :update]
  before_filter :login_required, :only => [:edit, :update]
  
  def new
    render :layout => 'public'
  end
  
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
      redirect_to admin_dashboard_path
    else
      render :action => 'new', :layout => 'public'
    end
  end
  
  def update
    current_account.update_attributes!(params[:account])
    redirect_to preferences_url
  rescue ActiveRecord::RecordInvalid
    render :edit
  end
  
  private
    def check_key
      redirect_to root_url unless params[:key] == CREATE_KEY
    end
end