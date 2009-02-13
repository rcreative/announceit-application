require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationHelper do
  
  include ApplicationHelper
  
  before do
    @account = Account.new(:subdomain => 'subdomain')
  end
  
  it 'should calculate the application domain correctly' do
    application_domain.should == 'test.host'
  end
  
  it 'should calculate the application domain correctly with a subdomain' do
    @request.should_receive(:host).any_number_of_times.and_return('subdomain.announceitapp.com')
    application_domain.should == 'announceitapp.com'
  end
  
  it 'should calculate the application host with port correctly' do
    application_host_with_port.should == 'test.host'
    
    @request.should_receive(:port) { 8221 }
    application_host_with_port.should == 'test.host:8221'
  end
  
  it 'should calculate the teaser using the subdomain' do
    teaser_host(@account).should == "subdomain.test.host"
  end
  
end