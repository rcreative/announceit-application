class BuiltinTemplatesDataset < Dataset::Base
  def load
    template_data = YAML.load(File.read(File.join(Rails.root, 'db', 'builtin_templates.yml')))
    
    id = create_record :template, :white_background, :name => 'White Background',
      :source => template_data['White Background']['source'],
      :styles => template_data['White Background']['styles']
    create_record :builtin_template, :template_id => id, :default_template => true
    
    id = create_record :template, :dark_background, :name => 'Dark Background',
      :source => template_data['Dark Background']['source'],
      :styles => template_data['Dark Background']['styles']
    create_record :builtin_template, :template_id => id
  end
end