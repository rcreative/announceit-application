module Admin
  class SettingsController < AbstractController
    before_filter :assign_teaser
    
    def update
      @teaser.update_attributes(params[:teaser])
      redirect_to :action => :show
    end
    
    protected
      def assign_teaser
        @teaser = current_account.teaser
      end
  end
end