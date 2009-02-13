class AddCustomDomainsToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :custom_domain, :string
    add_column :accounts, :domain_type, :string, :default => 'subdomain', :limit => 'subdomain'.size
  end

  def self.down
  end
end
