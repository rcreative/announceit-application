module Admin
  class ImagesController < AbstractController
    before_filter :assign_custom_template
    
    def create
      @custom_template.images.create!(params[:image])
      redirect_to edit_admin_teaser_url
    end
    
    def destroy
      template_image = @custom_template.template_images.find_by_image_id(params[:id])
      template_image.destroy
      redirect_to edit_admin_teaser_url
    end
    
    protected
      def assign_custom_template
        if @teaser.custom_template_selected?
          @custom_template = @teaser.template
        end
      end
  end
end