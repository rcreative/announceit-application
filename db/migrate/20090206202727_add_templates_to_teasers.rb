class AddTemplatesToTeasers < ActiveRecord::Migration
  class Teaser < ActiveRecord::Base
  end
  
  def self.up
    remove_column :teasers, :background_color
    add_column :teasers, :template_name, :string, :default => 'white_background'
    Teaser.update_all("template_name = 'white_background'")
  end
  
  def self.down
  end
end
