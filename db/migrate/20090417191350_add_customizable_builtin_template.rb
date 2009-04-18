class AddCustomizableBuiltinTemplate < ActiveRecord::Migration
  class Teaser < ActiveRecord::Base
  end
  
  def self.up
    add_column :builtin_templates, :default_customizable, :boolean, :default => false
    add_index :builtin_templates, :default_customizable
    
    data = YAML.load(File.read(File.join(Rails.root, 'db', 'builtin_templates.yml')))
    template = Template.create!(
      :name => 'Custom Template…',
      :source => data['Custom Template…']['source'],
      :styles => data['Custom Template…']['styles']
    )
    BuiltinTemplate.create!(:template => template, :default_customizable => true)
    
    Teaser.all(:conditions => {:template_id => nil}).each do |teaser|
      teaser.update_attribute(:template_id => 1) # White
    end
  end

  def self.down
  end
end
