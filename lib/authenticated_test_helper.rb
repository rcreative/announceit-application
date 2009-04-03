module AuthenticatedTestHelper
  # Sets the current account in the session from the account fixtures.
  def login_as(account)
    @request.session[:account_id] = account ? accounts(account).id : nil
  end

  def authorize_as(account)
    @request.env["HTTP_AUTHORIZATION"] = account ? ActionController::HttpAuthentication::Basic.encode_credentials(accounts(account).email, 'monkey') : nil
  end
  
  # rspec
  def mock_account
    account = mock_model(Account, :id => 1,
      :email  => 'email',
      :name   => 'U. Surname',
      :to_xml => "Account-in-XML", :to_json => "Account-in-JSON", 
      :errors => [])
    account
  end  
end
