require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'welcome' do
  it 'should be displayed when no subdomain' do
    navigate_to 'http://test.host'
    response.should be_showing('/signup')
  end
end

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

describe 'teaser page' do
  it 'should be displayed for a subdomain' do
    Account.should_receive(:find_by_subdomain).with('mecompany').and_return(Account.new(:name => 'My Company'))
    navigate_to 'http://mecompany.test.host'
    response.should have_text(/My Company/)
  end
end