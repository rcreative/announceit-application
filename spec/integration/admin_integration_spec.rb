require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'admin' do
  dataset :builtin_templates
  
  before do
    @account = stub_model(Account, :subdomain => 'mecompany', :update_attributes => true, :save => true)
    @teaser = stub_model(Teaser, :account => @account, :update_attributes => true)
    @template = stub_model(Template, :update_attributes => true)
    
    @account.stub!(:teaser).and_return(@teaser)
    
    @teaser.stub!(:subscribers).and_return([
      stub_model(Subscriber, :email => 'one@example.com'),
      stub_model(Subscriber, :email => 'two@example.com', :name => 'Two, Inc.')
    ])
    
    @custom_templates = []
    @teaser.stub!(:custom_templates).and_return(@custom_templates)
    @teaser.stub!(:template).and_return(@template)
    
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
    
    it 'should show the statistics of the last two months' do
      navigate_to '/dashboard?monthly'
      response.should render_template('admin/statistics/show')
      response.should have_tag('a.selected', 'Last 2 months')
    end
    
    it 'should allow changing the subdomain' do
      @account.should_receive(:update_attributes).with('subdomain' => 'meothername', 'domain_type' => 'subdomain').and_return(true)
      navigate_to '/domain/edit'
      submit_form :account => {:domain_type => 'subdomain', :subdomain => 'meothername'}
      response.should be_showing('/dashboard')
    end
    
    it 'should allow usage of a custom domain' do
      @account.should_receive(:update_attributes).with('domain_type' => 'custom', 'custom_domain' => 'somewhere.com').and_return(true)
      navigate_to '/domain/edit'
      submit_form :account => {:domain_type => 'custom', :custom_domain => 'somewhere.com'}
      response.should be_showing('/dashboard')
    end
    
    it 'should report errors changing the subdomain' do
      @account.should_receive(:update_attributes).with('subdomain' => 'meothername', 'domain_type' => 'subdomain').and_return(false)
      navigate_to '/domain/edit'
      submit_form :account => {:domain_type => 'subdomain', :subdomain => 'meothername'}
      response.should render_template('edit')
    end
  end
  
  it 'should list the subscribers' do
    navigate_to '/subscribers'
    response.should have_text(/one@example\.com/)
    response.should have_text(/Two, Inc./)
    response.should have_text(/two@example\.com/)
  end
  
  it 'should allow customizing the text for the built-in teasers' do
    @teaser.should_receive(:update_attributes).with('title' => 'Title', 'description' => 'Description').and_return(true)
    navigate_to '/teaser/edit'
    submit_form 'template_settings_form', :teaser => {:title => 'Title', :description => 'Description'}
    response.should be_showing('/teaser/edit')
  end
  
  it 'should allow selecting the template' do
    @teaser.should_receive(:update_attributes).with('template_id' => template_id(:dark_background).to_s, 'customize_selected' => '')
    navigate_to '/teaser/edit'
    submit_form 'template_select_form', :teaser => {:template_id => template_id(:dark_background)}
    response.should be_showing('/teaser/edit')
  end
  
  it 'should allow modifying custom template source and style content' do
    @teaser.custom_templates << stub_model(CustomTemplate, :template => @template)
    @template.should_receive(:update_attributes).with('source' => 'SM', 'styles' => 'SSM')
    navigate_to '/teaser/edit'
    submit_form 'template_settings_form', :template => {:source => 'SM', :styles => 'SSM'}
  end
  
  it 'should not allow modifying built-in template source and style content' do
    @template.should_not_receive(:update_attributes)
    put '/teaser', :template => {:source => 'SM', :styles => 'SSM'}
    response.should redirect_to('/teaser/edit')
  end
  
  it 'should allow user to upload images' do
    @teaser.custom_templates << stub_model(CustomTemplate, :template => @template)
    navigate_to '/teaser/edit'
    submit_form '#uploader', :image => {:upload => image_file}
    response.body.should include('small_image-48x48.png')
    @template.images.first.upload_file_name.should match(/small_image/)
  end
  
  it 'should allow user to delete images' do
    @teaser.custom_templates << stub_model(CustomTemplate, :template => @template)
    image = @template.images.create!(:upload => image_file)
    delete "/teaser/images/#{image.id}"
    response.should redirect_to('/teaser/edit')
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