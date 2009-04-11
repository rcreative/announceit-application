module Admin
  class StatisticsController < AbstractController
    before_filter :assign_activity_statistics
    
    def graph
      render :layout => false, :content_type => Mime::JSON
    end
    
    def show
      @subscriber_count = @teaser.subscribers.size
    end
    
    protected
      def assign_activity_statistics
        if params.has_key?('monthly')
          @statistics = MonthlyStatistics.new(@account, @teaser)
        else
          @statistics = DailyStatistics.new(@account, @teaser)
        end
      end
  end
end