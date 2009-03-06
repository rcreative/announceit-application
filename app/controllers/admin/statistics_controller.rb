module Admin
  class StatisticsController < AbstractController
    def graph
      render :layout => false
    end
  end
end