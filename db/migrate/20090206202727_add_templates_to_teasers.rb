class AddTemplatesToTeasers < ActiveRecord::Migration
  class Teaser < ActiveRecord::Base
  end
  
  def self.up
    change_column_default :teasers, :background_color, 'white'
    Teaser.update_all("background_color = 'white'")
  end
  
  def self.down
  end
end
