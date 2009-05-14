module Admin
  class TeasersController < AbstractController
    def update
      params[:teaser].delete(:logo) if params[:teaser][:logo].blank?
      success = @account.update_attributes(params[:account])
      success &= @teaser.update_attributes(params[:teaser])
      if @teaser.custom_template_selected?
        success &= @teaser.template.update_attributes(params[:template])
      end
      success ? redirect_to(:action => :edit) : render(:action => :edit)
    end
  end
end