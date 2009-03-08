module Admin
  class StatisticsController < AbstractController
    def graph
      @statistics = ActivityStatistics.new(@account, @teaser)
      render :layout => false
    end
  end
end