module Admin
  class SettingsController < AbstractController
    before_filter :assign_teaser
    
    def update
      if @account.update_attributes(params[:account]) &
         @teaser.update_attributes(params[:teaser])
        redirect_to :action => :show
      else
        render :action => :subdomain
      end
    end
    
    protected
      def assign_teaser
        @teaser = current_account.teaser
      end
  end
end