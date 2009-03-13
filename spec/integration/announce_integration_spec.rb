require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'welcome' do
  it 'should be displayed when no subdomain' do
    navigate_to 'http://test.host'
    response.should be_showing('/')
  end
end

describe 'signup' do
  it 'should create an account and show settings page' do
    navigate_to '/signup?key=dk3su29sw'
    submit_form :account => {
      :name => 'Me Company', :email => 'me@example.com',
      :username => '2kso2df', :password => 'password', :password_confirmation => 'password',
      :subdomain => 'mecompany'}
    response.should be_showing('/settings')
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

describe 'teaser page' do
  before do
    @account = stub_model(Account, :subdomain => 'mecompany')
    @teaser = Teaser.create!(:account => @account)
    @account.stub!(:teaser).and_return(@teaser)
    Account.stub!(:find_by_subdomain).and_return(@account)
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
    Account.stub!(:authenticate).and_return(@account)
    Account.stub!(:find_by_id).and_return(@account)
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
  
  it 'should create a visit for a visitor who has not visited within the past hour' do
    visitor = @teaser.visitors.create!
    cookies["teaser.#{@teaser.id}.visitor"] = visitor.cookie
    lambda do
      navigate_to 'http://mecompany.test.host'
    end.should change(Visit, :count).by(1)
    Visit.last.visitor_id.should == visitor.id
  end
  
  it 'should not track account owners'
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
end

describe 'admin' do
  before do
    @account = stub_model(Account, :subdomain => 'mecompany', :update_attributes => true)
    @teaser = stub_model(Teaser, :account => @account, :template_name => 'white_background', :update_attributes => true)
    @account.stub!(:teaser).and_return(@teaser)
    
    @teaser.stub!(:subscribers).and_return([
      stub_model(Subscriber, :email => 'one@example.com'),
      stub_model(Subscriber, :email => 'two@example.com', :name => 'Two, Inc.')
    ])
    
    Account.stub!(:authenticate).and_return(@account)
    Account.stub!(:find_by_id).and_return(@account)
    login_as @account
  end
  
  describe 'dashboard' do
    it 'should show the statistics of the last seven days' do
      navigate_to '/dashboard'
      response.should render_template('admin/statistics/show')
      response.should have_tag('a.selected', 'Past 7 days')
    end
  end
  
  it 'should list the subscribers' do
    navigate_to '/subscribers'
    response.should have_text(/one@example\.com/)
    response.should have_text(/Two, Inc./)
    response.should have_text(/two@example\.com/)
  end
  
  it 'should allow changing the subdomain' do
    @account.should_receive(:update_attributes).with('subdomain' => 'meothername', 'domain_type' => 'subdomain').and_return(true)
    navigate_to '/settings/subdomain'
    submit_form :account => {:domain_type => 'subdomain', :subdomain => 'meothername'}
    response.should render_template('show')
  end
  
  it 'should allow usage of a custom domain' do
    @account.should_receive(:update_attributes).with('domain_type' => 'custom', 'custom_domain' => 'somewhere.com').and_return(true)
    navigate_to '/settings/subdomain'
    submit_form :account => {:domain_type => 'custom', :custom_domain => 'somewhere.com'}
    response.should render_template('show')
  end
  
  it 'should report errors changing the subdomain' do
    @account.should_receive(:update_attributes).with('subdomain' => 'meothername', 'domain_type' => 'subdomain').and_return(false)
    navigate_to '/settings/subdomain'
    submit_form :account => {:domain_type => 'subdomain', :subdomain => 'meothername'}
    response.should render_template('subdomain')
  end
  
  it 'should allow customizing the text for the teaser' do
    @teaser.should_receive(:update_attributes).with('title' => 'Title', 'description' => 'Description').and_return(true)
    navigate_to '/settings'
    submit_form 'title_and_description_form', :teaser => {:title => 'Title', :description => 'Description'}
    response.should be_showing('/settings')
  end
  
  it 'should allow selecting the template background' do
    @teaser.should_receive(:update_attributes).with('template_name' => 'dark_background')
    navigate_to '/settings'
    submit_form 'template_form', :teaser => {:template_name => 'dark_background'}
    response.should be_showing('/settings')
  end
  
  it 'should allow downloading a text file containing all the email addresses' do
    navigate_to '/subscribers.txt'
    response.content_type.should == 'text/plain'
    response.body.should == 'one@example.com, two@example.com'
  end
  
  it 'should allow downloading a csv file containing all names and email addresses' do
    navigate_to '/subscribers.csv'
    response.content_type.should == 'text/csv'
    response.headers['Content-Disposition'].should == 'attachment; filename=subscribers.csv'
    response.body.should match(/^Name,Email\n,one@example\.com\n"Two, Inc.",two@example\.com$/m)
  end
  
  it 'should allow admin to unsubscribe someone' do
    subscriber = @teaser.subscribers.first
    subscriber.should_receive(:destroy)
    @teaser.subscribers.should_receive(:find).with(subscriber.id.to_s).and_return(subscriber)
    
    navigate_to '/subscribers'
    click_on :link => "/subscribers/#{subscriber.id}"
    response.should be_showing('/subscribers')
  end
end