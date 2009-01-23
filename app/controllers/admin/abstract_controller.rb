module Admin
  class AbstractController < ApplicationController
    before_filter :login_required
    before_filter :assign_account
    before_filter :assign_teaser
    
    private
      def assign_account
        @account = current_account
      end
  end
end