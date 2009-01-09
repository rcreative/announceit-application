class ReleaseOne < ActiveRecord::Migration
  def self.up
    create_table :accounts, :force => true do |t|
      t.string :login, :limit => 100
      t.string :name
      t.string :email, :limit => 100
      t.string :subdomain
      t.string :crypted_password, :limit => 40
      t.string :salt, :limit => 40
      t.string :remember_token, :limit => 40
      t.datetime :remember_token_expires_at
      t.timestamps
    end
  end

  def self.down
  end
end
