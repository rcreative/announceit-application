class AddCustomDomainsToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :custom_domain, :string
  end

  def self.down
  end
end
