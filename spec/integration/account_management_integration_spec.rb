require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'signup' do
  it 'should create an account and show dashboard' do
    navigate_to '/signup?key=dk3su29sw'
    submit_form :account => {
      :name => 'Me Company', :email => 'me@example.com',
      :username => '2kso2df', :password => 'password', :password_confirmation => 'password',
      :subdomain => 'mecompany'}
    response.should be_showing('/dashboard')
  end
  
  it 'should require our special flag for now' do
    get '/signup'
    response.should redirect_to('/')
    
    post '/accounts', :account => {
      :name => 'Me Company', :email => 'me@example.com',
      :username => '2kso2df', :password => 'password', :password_confirmation => 'password',
      :subdomain => 'mecompany'}
    response.should redirect_to('/')
  end
end
