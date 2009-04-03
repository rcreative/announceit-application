require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'signup' do
  it 'should create an account and show dashboard' do
    navigate_to '/signup?key=dk3su29sw'
    submit_form :account => {
      :name => 'Me Company', :email => 'me@example.com',
      :password => 'password', :password_confirmation => 'password',
      :subdomain => 'mecompany'}
    response.should be_showing('/dashboard')
  end
  
  it 'should require our special flag for now' do
    get '/signup'
    response.should redirect_to('/')
    
    post '/accounts', :account => {
      :name => 'Me Company', :email => 'me@example.com',
      :password => 'password', :password_confirmation => 'password',
      :subdomain => 'mecompany'}
    response.should redirect_to('/')
  end
end

describe 'account editing' do
  dataset :accounts
  
  before { login_as :quentin }
  
  it 'should allow changing the name and email' do
    navigate_to '/preferences'
    submit_form :account => {:name => 'New Name', :email => 'quentin2@example.com'}
    account = accounts(:quentin)
    account.name.should == 'New Name'
    account.email.should == 'quentin2@example.com'
  end
  
  it 'should allow changing password' do
    submit_to account_path(account_id(:quentin)), {:account => {
      :name => current_account.name, :email => current_account.email,
      :password => 'my_new_one', :password_confirmation => 'my_new_one'}},
      :put
    account = accounts(:quentin)
    account.authenticated?('my_new_one').should be_true
  end
  
  it 'should report form errors' do
    submit_to account_path(account_id(:quentin)), {:account => {
      :name => current_account.name, :email => ''}}, :put
    response.should be_showing(account_path(account_id(:quentin)))
  end
end