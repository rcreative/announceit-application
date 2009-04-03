require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'welcome' do
  it 'should be displayed when no subdomain' do
    navigate_to 'http://test.host'
    response.should be_showing('/')
  end
end

describe 'teaser page' do
  before do
    @account = stub_model(Account, :subdomain => 'mecompany')
    @teaser = Teaser.create!(:account => @account)
    @account.stub!(:teaser).and_return(@teaser)
    Account.stub!(:find_by_subdomain).and_return(@account)
    Account.stub!(:authenticate).and_return(@account)
    Account.stub!(:find_by_id).and_return(@account)
  end
  
  it 'should be displayed for a subdomain' do
    Account.should_receive(:find_by_subdomain).with('mecompany').and_return(@account)
    navigate_to 'http://mecompany.test.host'
  end
  
  it 'should be displayed for a subdomain with more tlds' do
    Account.should_receive(:find_by_subdomain).with('mecompany').and_return(@account)
    navigate_to 'http://mecompany.a.b.test.host'
  end
  
  it 'should be displayed for a custom domain name' do
    Account.should_receive(:find_by_custom_domain).with('somewherespecial.com').and_return(@account)
    navigate_to 'http://somewherespecial.com'
  end
  
  it 'should indicate when no teaser is found for a subdomain' do
    Account.should_receive(:find_by_subdomain).with('mecompany').and_return(nil)
    get 'http://mecompany.test.host'
    response.should redirect_to('/')
  end
  
  it 'should render the selected background' do
    login_as @account
    navigate_to '/teaser'
    response.should render_template('white_background')
  end
  
  it 'should store a "permanent" cookie useful for detecting a returning visitor' do
    lambda do
      navigate_to 'http://mecompany.test.host'
    end.should change(Visitor, :count).by(1)
    cookies["teaser.#{@teaser.id}.visitor"].should == Visitor.last.cookie
  end
  
  it 'should create a visit for a visitor' do
    visitor = @teaser.visitors.create!
    cookies["teaser.#{@teaser.id}.visitor"] = visitor.cookie
    lambda do
      navigate_to 'http://mecompany.test.host'
    end.should change(Visit, :count).by(1)
    Visit.last.visitor_id.should == visitor.id
  end
  
  it 'should create a new visitor and update cookie when existing cookie not found' do
    cookies["teaser.#{@teaser.id}.visitor"] = 'something not found'
    lambda do
      navigate_to 'http://mecompany.test.host'
    end.should change(Visitor, :count).by(1)
    cookies["teaser.#{@teaser.id}.visitor"].should == Visitor.last.cookie
  end
  
  it 'should not create a visit for a visitor who has visited within the last hour' do
    visitor = @teaser.visitors.create!
    visit = visitor.visits.create!
    cookies["teaser.#{@teaser.id}.visitor"] = visitor.cookie
    recent_visit_time = 5.minutes.from_now
    lambda do
      Time.stub!(:now).and_return(recent_visit_time)
      navigate_to 'http://mecompany.test.host'
    end.should_not change(Visit, :count)
    visit.reload.visited_at.to_s.should == recent_visit_time.to_s
  end
  
  it 'should not create a visit for a visitor who is logged in as the account owner' do
    login_as @account
    visitor = @teaser.visitors.create!
    cookies["teaser.#{@teaser.id}.visitor"] = visitor.cookie
    lambda do
      navigate_to '/teaser'
    end.should_not change(Visit, :count)
  end
end

describe 'subscribe' do
  before do
    @account = stub_model(Account, :subdomain => 'mecompany')
    @teaser = Teaser.create!(:account => @account)
    @account.stub!(:teaser).and_return(@teaser)
    Account.stub!(:find_by_subdomain).and_return(@account)
  end
  
  it 'should create a Subscriber for the Teaser' do
    navigate_to 'http://mecompany.test.host'
    submit_form :subscriber => {:name => 'Johnny', :email => 'johnny@example.com'}
    response.should be_showing('/teaser')
    Subscriber.last.teaser.should == @teaser
  end
  
  it 'should indicate form errors' do
    navigate_to 'http://mecompany.test.host'
    submit_form :subscriber => {:email => '@example.com'}
    response.should be_showing('/subscribe')
    response.should have_text(/errors/)
  end
  
  it 'should associate the current visitor, subscriber with a subscribe' do
    visitor = @teaser.visitors.create!
    cookies["teaser.#{@teaser.id}.visitor"] = visitor.cookie
    submit_to 'http://mecompany.test.host/subscribe', :subscriber => {:name => 'Johnny', :email => 'johnny@example.com'}
    subscribe = Subscribe.last
    subscribe.visitor.should == visitor
    subscribe.subscriber_id.should_not be_nil
    subscribe.subscribed_on.should == Date.today
  end
end