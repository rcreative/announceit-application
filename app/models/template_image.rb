class TemplateImage < ActiveRecord::Base
  belongs_to :template
  belongs_to :image
  
  after_destroy :destroy_image
  
  protected
    def destroy_image
      Image.delete(image_id) unless TemplateImage.exists?(:image_id => image_id)
    end
end