require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'signup' do
  it 'should create an account and show dashboard' do
    navigate_to '/signup'
    submit_form :account => {
      :name => 'Me Company', :email => 'me@example.com',
      :login => '2kso2df', :password => 'password', :password_confirmation => 'password',
      :subdomain => 'mecompany'}
    response.should be_showing('/dashboard')
  end
end