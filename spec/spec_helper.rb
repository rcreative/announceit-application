# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'
require 'spec/integration'

require 'vizres'
Vizres::RESPONSE_URI.sub!(/localhost:3000/, 'announce.local')

module ModelAttributeMethods
  def account_attributes
    {
      :email => 'quire@example.com',
      :password => 'quire69', :password_confirmation => 'quire69',
      :subdomain => 'quire'
    }
  end
  
  def subscriber_attributes(updates = {})
    {:email => 'quag@example.com'}.merge(updates)
  end
end

module ModelFactoryMethods
  def create_account(attributes = {})
    Account.create(account_attributes.merge(attributes))
  end
end

require 'dataset'
class Dataset::Base
  include ModelAttributeMethods
  include ModelFactoryMethods
end
class Test::Unit::TestCase
  include ModelAttributeMethods
  include ModelFactoryMethods
  include Dataset
  datasets_directory "#{RAILS_ROOT}/spec/datasets"
end


include AuthenticatedTestHelper

module IntegrationExampleExtensions
  def login_as(account)
    if account.nil?
      delete session_path
    else
      account = accounts(account) if Symbol === account
      post session_url, :email => account.email, :password => "monkey"
    end
  end
  
  def current_account
    controller.send :current_account
  end
  
  def image_file
    ActionController::TestUploadedFile.new(File.join(Rails.root, %w(spec fixtures small_image.png)), "image/png", true)
  end
end

Spec::Runner.configure do |config|
  config.include IntegrationExampleExtensions, :type => :integration
  
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  # config.mock_with :rr

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  # 
  # For more information take a look at Spec::Example::Configuration and Spec::Runner
end
