class RemoveUsername < ActiveRecord::Migration
  def self.up
    remove_column :accounts, :username
    add_index :accounts, :email
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
