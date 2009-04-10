module Admin
  class TeasersController < AbstractController
    def update
      if @account.update_attributes(params[:account]) & @teaser.update_attributes(params[:teaser])
        redirect_to :action => :edit
      else
        render :action => :edit
      end
    end
  end
end