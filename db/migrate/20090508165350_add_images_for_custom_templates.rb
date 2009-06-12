class AddImagesForCustomTemplates < ActiveRecord::Migration
  def self.up
    create_table :images, :force => true do |t|
      t.string :upload_file_name
      t.string :upload_content_type
      t.integer :upload_file_size
      t.datetime :upload_updated_at
    end
    
    create_table :template_images, :force => true do |t|
      t.belongs_to :template
      t.belongs_to :image
    end
    add_index :template_images, :template_id
    
    template = Template.find_by_name('Mission Control')
    source, styles = template.source.dup, template.styles.dup
    Dir[Rails.root.join('public/mc/images/*.png')].each do |path|
      image = template.images.create!(:upload => File.open(path))
      source.gsub!("/mc/images/#{File.basename(path)}", image.upload.url)
      styles.gsub!("/mc/images/#{File.basename(path)}", image.upload.url)
    end
    template.update_attributes(:source => source, :styles => styles)
    
    pattern = /(  <div id="logo">.*?<r:logo \/>.*?<\/div>)/mi
    Template.all.each do |template|
      template.source.sub!(pattern, "  <r:if_logo>\n      <div id=\"logo\">\n        <r:logo />\n      </div>\n    </r:if_logo>")
      template.save!
    end
  end

  def self.down
  end
end
