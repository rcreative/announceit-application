# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  layout 'public'
  
  def create
    logout_keeping_session!
    account = Account.authenticate(params[:username], params[:password])
    if account
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_account = account
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      redirect_back_or_default('/dashboard')
      flash[:notice] = "Logged in successfully"
    else
      note_failed_signin
      @login       = params[:username]
      @remember_me = params[:remember_me]
      render :action => 'new'
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Invalid username or password."
    logger.warn "Failed login for '#{params[:username]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
