module Admin
  class StatisticsController < AbstractController
    before_filter :assign_activity_statistics
    
    def graph
      render :layout => false
    end
    
    def show
      @subscriber_count = @teaser.subscribers.size
    end
    
    private
      def assign_activity_statistics
        @statistics = ActivityStatistics.new(@account, @teaser)
      end
  end
end