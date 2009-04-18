class AddCustomizableBuiltinTemplate < ActiveRecord::Migration
  def self.up
    add_column :builtin_templates, :default_customizable, :boolean, :default => false
    add_index :builtin_templates, :default_customizable
    
    data = YAML.load(File.read(File.join(Rails.root, 'db', 'builtin_templates.yml')))
    
    Template.find(1).update_attributes!(
      :source => data['White Background']['source'],
      :styles => data['White Background']['styles']
    )
    
    Template.find(2).update_attributes!(
      :source => data['Dark Background']['source'],
      :styles => data['Dark Background']['styles']
    )
    
    template = Template.create!(
      :name => 'Custom Template…',
      :source => data['Custom Template…']['source'],
      :styles => data['Custom Template…']['styles']
    )
    BuiltinTemplate.create!(:template => template, :default_customizable => true)
    
    
    data = YAML.load(File.read(File.join(Rails.root, 'db', 'missioncontrol_template.yml')))
    Template.find(3).update_attributes!(
      :source => data['source'],
      :styles => data['styles']
    )
    
    Teaser.all(:conditions => {:template_id => nil}).each do |teaser|
      teaser.update_attribute(:template_id => 1) # White
    end
  end

  def self.down
  end
end
