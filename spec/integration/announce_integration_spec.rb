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
      :login => '2kso2df', :password => 'password', :password_confirmation => 'password',
      :subdomain => 'mecompany'}
    response.should be_showing('/settings')
  end
  
  it 'should require our special flag for now' do
    get '/signup'
    response.should redirect_to('/')
    
    post '/accounts', :account => {
      :name => 'Me Company', :email => 'me@example.com',
      :login => '2kso2df', :password => 'password', :password_confirmation => 'password',
      :subdomain => 'mecompany'}
    response.should redirect_to('/')
  end
end

describe 'teaser page' do
  before do
    @account = stub_model(Account, :subdomain => 'mecompany')
    @teaser = Teaser.create!(:account => @account)
    @account.stub!(:teaser).and_return(@teaser)
  end
  
  it 'should be displayed for a subdomain' do
    Account.should_receive(:find_by_subdomain).with('mecompany').and_return(@account)
    navigate_to 'http://mecompany.test.host'
  end
  
  it 'should be displayed for a subdomain with more tlds' do
    Account.should_receive(:find_by_subdomain).with('mecompany').and_return(@account)
    navigate_to 'http://mecompany.a.b.test.host'
  end
  
  it 'should indicate when no teaser is found for a subdomain' do
    Account.should_receive(:find_by_subdomain).with('mecompany').and_return(nil)
    get 'http://mecompany.test.host'
    response.response_code.should be(404)
  end
  
  it 'should render the selected background' do
    Account.stub!(:authenticate).and_return(@account)
    Account.stub!(:find_by_id).and_return(@account)
    login_as @account
    navigate_to '/teaser'
    response.should render_template('white_background')
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
end

describe 'admin' do
  before do
    @account = stub_model(Account, :subdomain => 'mecompany', :update_attributes => true)
    @teaser = stub_model(Teaser, :account => @account, :background_color => 'white', :update_attributes => true)
    @account.stub!(:teaser).and_return(@teaser)
    
    @teaser.stub!(:subscribers).and_return([
      stub_model(Subscriber, :email => 'one@example.com'),
      stub_model(Subscriber, :email => 'two@example.com', :name => 'Two, Inc.')
    ])
    
    Account.stub!(:authenticate).and_return(@account)
    Account.stub!(:find_by_id).and_return(@account)
    login_as @account
  end
  
  it 'should list the subscribers' do
    navigate_to '/subscribers'
    response.should have_text(/one@example\.com/)
    response.should have_text(/Two, Inc./)
    response.should have_text(/two@example\.com/)
  end
  
  it 'should allow changing the subdomain' do
    @account.should_receive(:update_attributes).with('subdomain' => 'meothername').and_return(true)
    navigate_to '/settings/subdomain'
    submit_form :account => {:subdomain => 'meothername'}
    response.should render_template('show')
  end
  
  it 'should report errors changing the subdomain' do
    @account.should_receive(:update_attributes).with('subdomain' => 'meothername').and_return(false)
    navigate_to '/settings/subdomain'
    submit_form :account => {:subdomain => 'meothername'}
    response.should render_template('subdomain')
  end
  
  it 'should allow customizing the text for the teaser' do
    @teaser.should_receive(:update_attributes).with('title' => 'Title', 'description' => 'Description').and_return(true)
    navigate_to '/settings'
    submit_form 'title_and_description_form', :teaser => {:title => 'Title', :description => 'Description'}
    response.should be_showing('/settings')
  end
  
  it 'should allow selecting the template background' do
    @teaser.should_receive(:update_attributes).with('background_color' => 'dark')
    navigate_to '/settings'
    submit_form 'template_form', :teaser => {:background_color => 'dark'}
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