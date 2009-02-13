class RenameLoginToUsername < ActiveRecord::Migration
  def self.up
    rename_column :accounts, :login, :username
  end

  def self.down
  end
end
