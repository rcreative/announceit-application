# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe Account do
  dataset :accounts
  
  it 'requires subdomain when no custom' do
    lambda do
      u = create_account(:subdomain => nil)
      u.errors.on(:subdomain).should_not be_nil
    end.should_not change(Account, :count)
  end
  
  it 'requires unique subdomain' do
    lambda do
      u = create_account(:subdomain => 'taken')
      u.domain_type.should == 'subdomain'
      u = create_account(:subdomain => 'taken')
      u.errors.on(:subdomain).should_not be_nil
    end.should change(Account, :count).by(1)
  end
  
  it 'should ensure subdomains are not our special ones' do
    %w(mail ftp pop smtp ssh imap).each do |subdomain|
      create_account(:subdomain => subdomain).errors.on(:subdomain).should_not be_nil
    end
  end
  
  it 'should allow custom domain' do
    lambda do
      u = create_account(:subdomain => '', :custom_domain => 'mecustomdomain.com', :domain_type => 'custom')
      u.domain_type.should == 'custom'
      u.subdomain.should be_nil
    end.should change(Account, :count)
  end
  
  it 'requires password' do
    lambda do
      u = create_account(:password => nil)
      u.errors.on(:password).should_not be_nil
    end.should_not change(Account, :count)
  end

  it 'requires password confirmation' do
    lambda do
      u = create_account(:password_confirmation => nil)
      u.errors.on(:password_confirmation).should_not be_nil
    end.should_not change(Account, :count)
  end

  it 'requires email' do
    lambda do
      u = create_account(:email => nil)
      u.errors.on(:email).should_not be_nil
    end.should_not change(Account, :count)
  end

  describe 'allows legitimate emails:' do
    ['foo@bar.com', 'foo@newskool-tld.museum', 'foo@twoletter-tld.de', 'foo@nonexistant-tld.qq',
     'r@a.wk', '1234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890@gmail.com',
     'hello.-_there@funnychar.com', 'uucp%addr@gmail.com', 'hello+routing-str@gmail.com',
     'domain@can.haz.many.sub.doma.in', 'student.name@university.edu'
    ].each do |email_str|
      it "'#{email_str}'" do
        lambda do
          u = create_account(:email => email_str)
          u.errors.on(:email).should     be_nil
        end.should change(Account, :count).by(1)
      end
    end
  end
  describe 'disallows illegitimate emails' do
    ['!!@nobadchars.com', 'foo@no-rep-dots..com', 'foo@badtld.xxx', 'foo@toolongtld.abcdefg',
     'Iñtërnâtiônàlizætiøn@hasnt.happened.to.email', 'need.domain.and.tld@de', "tab\t", "newline\n",
     'r@.wk', '1234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890@gmail2.com',
     # these are technically allowed but not seen in practice:
     'uucp!addr@gmail.com', 'semicolon;@gmail.com', 'quote"@gmail.com', 'tick\'@gmail.com', 'backtick`@gmail.com', 'space @gmail.com', 'bracket<@gmail.com', 'bracket>@gmail.com'
    ].each do |email_str|
      it "'#{email_str}'" do
        lambda do
          u = create_account(:email => email_str)
          u.errors.on(:email).should_not be_nil
        end.should_not change(Account, :count)
      end
    end
  end

  describe 'allows legitimate names:' do
    ['Andre The Giant (7\'4", 520 lb.) -- has a posse',
     '', '1234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890',
    ].each do |name_str|
      it "'#{name_str}'" do
        lambda do
          u = create_account(:name => name_str)
          u.errors.on(:name).should     be_nil
        end.should change(Account, :count).by(1)
      end
    end
  end
  describe "disallows illegitimate names" do
    ["tab\t", "newline\n",
     '1234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_',
     ].each do |name_str|
      it "'#{name_str}'" do
        lambda do
          u = create_account(:name => name_str)
          u.errors.on(:name).should_not be_nil
        end.should_not change(Account, :count)
      end
    end
  end

  it 'resets password' do
    accounts(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    Account.authenticate('quentin@example.com', 'new password').should == accounts(:quentin)
  end

  it 'does not rehash password' do
    accounts(:quentin).update_attributes(:email => 'quentin2@example.com')
    Account.authenticate('quentin2@example.com', 'monkey').should == accounts(:quentin)
  end

  #
  # Authentication
  #

  it 'authenticates account' do
    Account.authenticate('quentin@example.com', 'monkey').should == accounts(:quentin)
  end

  it "doesn't authenticate account with bad password" do
    Account.authenticate('quentin@example.com', 'invalid_password').should be_nil
  end

  it "doesn't authenticate a user against a hard-coded old-style password" do
    create_record :account,
      :email => 'salty_dog@example.com',
      :salt => '7e3041ebc2fc05a40c60028e2c4901a81035d3cd',
      :crypted_password => '00742970dc9e6319f8019fd54864d3ea740f04b1' # test
    Account.authenticate('salty_dog@example.com', 'test').should be_nil
  end

  # New installs should bump this up and set REST_AUTH_DIGEST_STRETCHES to give a 10ms encrypt time or so
  desired_encryption_expensiveness_ms = 0.1
  it "takes longer than #{desired_encryption_expensiveness_ms}ms to encrypt a password" do
    test_reps = 100
    start_time = Time.now; test_reps.times{ Account.authenticate('quentin@example.com', 'monkey'+rand.to_s) }; end_time   = Time.now
    auth_time_ms = 1000 * (end_time - start_time)/test_reps
    auth_time_ms.should > desired_encryption_expensiveness_ms
  end

  #
  # Authentication
  #

  it 'sets remember token' do
    accounts(:quentin).remember_me
    accounts(:quentin).remember_token.should_not be_nil
    accounts(:quentin).remember_token_expires_at.should_not be_nil
  end

  it 'unsets remember token' do
    accounts(:quentin).remember_me
    accounts(:quentin).remember_token.should_not be_nil
    accounts(:quentin).forget_me
    accounts(:quentin).remember_token.should be_nil
  end

  it 'remembers me for one week' do
    now = Time.now
    Time.stub!(:now).and_return(now)
    accounts(:quentin).remember_me_for 1.week
    accounts(:quentin).remember_token.should_not be_nil
    accounts(:quentin).remember_token_expires_at.should_not be_nil
    accounts(:quentin).remember_token_expires_at.utc.to_s.should == (now + 1.week).utc.to_s
  end

  it 'remembers me until one week' do
    time = 1.week.from_now.utc
    accounts(:quentin).remember_me_until time
    accounts(:quentin).remember_token.should_not be_nil
    accounts(:quentin).remember_token_expires_at.should_not be_nil
    accounts(:quentin).remember_token_expires_at.utc.to_s.should == time.to_s
  end

  it 'remembers me default two weeks' do
    now = Time.now
    Time.stub!(:now).and_return(now)
    accounts(:quentin).remember_me
    accounts(:quentin).remember_token.should_not be_nil
    accounts(:quentin).remember_token_expires_at.should_not be_nil
    accounts(:quentin).remember_token_expires_at.utc.to_s.should == (now + 2.weeks).utc.to_s
  end
end
