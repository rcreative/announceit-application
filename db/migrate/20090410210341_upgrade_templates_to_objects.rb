class UpgradeTemplatesToObjects < ActiveRecord::Migration
  class Template < ActiveRecord::Base; end
  
  class Teaser < ActiveRecord::Base
    belongs_to :template, :class_name => UpgradeTemplatesToObjects::Template.name
  end
  
  class BuiltinTemplate < ActiveRecord::Base
    belongs_to :template, :class_name => UpgradeTemplatesToObjects::Template.name
  end
  
  class CustomTemplate < ActiveRecord::Base
    belongs_to :teaser, :class_name => UpgradeTemplatesToObjects::Teaser.name
    belongs_to :template, :class_name => UpgradeTemplatesToObjects::Template.name
  end
  
  def self.up
    create_table :builtin_templates, :force => true do |t|
      t.belongs_to :template
      t.boolean :default_template, :default => false
    end
    
    create_table :custom_templates, :force => true do |t|
      t.belongs_to :teaser
      t.belongs_to :template
    end
    
    create_table :templates, :force => true do |t|
      t.string :name
      t.text :source
      t.text :styles
      t.timestamps
    end
    
    add_column :teasers, :template_id, :integer
    migrate_templates
    remove_column :teasers, :template_name
  end
  
  def self.migrate_templates
    template_data = YAML.load(File.read(File.join(Rails.root, 'db', 'builtin_templates.yml')))
    
    white = Template.create!(
      :name => 'White Background',
      :source => template_data['White Background']['source'],
      :styles => template_data['White Background']['styles']
    )
    BuiltinTemplate.create!(:template => white, :default_template => true)
    
    dark = Template.create!(
      :name => 'Dark Background',
      :source => template_data['Dark Background']['source'],
      :styles => template_data['Dark Background']['styles']
    )
    BuiltinTemplate.create!(:template => dark)
    
    Teaser.all.each do |teaser|
      if teaser.account_id == 2 && teaser.template_name != 'white_background'
        migrate_codename_mc(teaser)
      else
        case teaser.template_name
        when 'white_background'
          teaser.template = white
        when 'dark_background'
          teaser.template = dark
        end
      end
      teaser.save!
    end
  end
  
  def self.migrate_codename_mc(teaser)
    template_data = YAML.load(File.read(File.join(Rails.root, 'db', 'missioncontrol_template.yml')))
    template = Template.create!(
      :name => 'Mission Control',
      :source => template_data['source'],
      :styles => template_data['styles']
    )
    CustomTemplate.create!(:template => template, :teaser => teaser)
    teaser.template = template
  end
  
  def self.down
  end
end
