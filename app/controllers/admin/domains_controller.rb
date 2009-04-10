module Admin
  class DomainsController < AbstractController
    def update
      if @account.update_attributes(params[:account])
        redirect_to admin_dashboard_url
      else
        render :action => :edit
      end
    end
  end
end