require 'digest/sha1'

class Account < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  
  has_one :teaser
  after_create :create_teaser
  
  cattr_accessor :subdomain_regex
  self.subdomain_regex = /\w+|^$/
  
  validates_format_of       :name,  :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,  :maximum => 100, :allow_nil => true

  validates_presence_of     :email
  validates_length_of       :email, :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email, :with => Authentication.email_regex, :message => Authentication.bad_email_message

  validates_length_of       :subdomain, :maximum => 40, :if => lambda {|o| o.domain_type != 'custom'}
  validates_format_of       :subdomain, :with => self.subdomain_regex
  validates_exclusion_of    :subdomain, :in => %w(mail ftp pop smtp ssh imap)
  validates_uniqueness_of   :subdomain, :case_sensitive => false, :allow_nil => true

  validates_presence_of     :custom_domain, :if => lambda {|o| o.domain_type == 'custom'}
  validates_exclusion_of    :custom_domain, :in => Rails.configuration.announce.tlds
  validates_uniqueness_of   :custom_domain, :case_sensitive => false, :allow_nil => true
  
  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :email, :name, :password, :password_confirmation, :domain_type, :custom_domain, :subdomain

  before_save :clear_unused_domain_setting
  
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  def self.authenticate(email, password)
    return nil if email.blank? || password.blank?
    u = find_by_email(email.downcase) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end
  
  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end
  
  protected
    def clear_unused_domain_setting
      if domain_type == 'custom'
        self.subdomain = nil
      else
        self.custom_domain = nil
      end
    end
end
