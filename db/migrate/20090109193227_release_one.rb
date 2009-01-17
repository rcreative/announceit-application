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
    
    create_table :teasers, :force => true do |t|
      t.belongs_to :account
      t.string :background_color, :limit => 15
      t.string :logo_file_name
      t.string :logo_content_type
      t.integer :logo_file_size
      t.datetime :logo_updated_at
      t.timestamps
    end
    
    create_table :subscribers, :force => true do |t|
      t.belongs_to :teaser
      t.string :name
      t.string :email, :limit => 100
      t.timestamps
    end
  end

  def self.down
  end
end
