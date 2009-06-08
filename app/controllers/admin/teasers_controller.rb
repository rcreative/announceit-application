module Admin
  class TeasersController < AbstractController
    def update
      teaser_params = params[:teaser] || {}
      teaser_params.delete(:logo) if teaser_params[:logo].blank?
      success = @account.update_attributes(params[:account])
      success &= @teaser.update_attributes(teaser_params)
      if @teaser.custom_template_selected?
        success &= @teaser.template.update_attributes(params[:template])
      end
      success ? redirect_to(:action => :edit) : render(:action => :edit)
    end
  end
end
