module Admin
  class AbstractController < ApplicationController
    before_filter :login_required
  end
end