module Admin
  class SubscribersController < AbstractController
    def index
      @subscribers = @teaser.subscribers.paginate :page => params[:page], :per_page => 25
    end
  end
end