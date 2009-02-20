module Admin
  class DashboardsController < AbstractController
    def graph
      render :layout => false
    end
  end
end