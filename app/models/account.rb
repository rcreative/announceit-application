require 'digest/sha1'

class Account < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  
  has_one :teaser
  after_create :create_teaser
  
  cattr_accessor :subdomain_regex
  self.subdomain_regex = /\w+/
  
  validates_presence_of     :login
  validates_length_of       :login, :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login, :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :name,  :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,  :maximum => 100, :allow_nil => true

  validates_presence_of     :email
  validates_length_of       :email, :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email, :with => Authentication.email_regex, :message => Authentication.bad_email_message

  validates_length_of       :subdomain, :maximum => 40, :allow_nil => false
  validates_format_of       :subdomain, :with => self.subdomain_regex
  validates_exclusion_of    :subdomain, :in => %w(mail ftp pop smtp ssh imap)
  validates_uniqueness_of   :subdomain

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation, :subdomain

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end
end
