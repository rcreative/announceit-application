class AccountsDataset < Dataset::Base
  uses :builtin_templates
  
  def load
    create_record :account, :quentin,
      :email => 'quentin@example.com',
      :salt => '356a192b7913b04c54574d18c28d46e6395428ab', # SHA1('0')
      :crypted_password => '5656ffa11c386f390714e9864f5ee93daac34913', # 'monkey'
      :created_at => 5.days.ago,
      :remember_token_expires_at => 1.day.from_now,
      :remember_token => '77de68daecd823babbb58edb1c8e14d7106e83bb',
      :subdomain => 'quentin'
  end
end