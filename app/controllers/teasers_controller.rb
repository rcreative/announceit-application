class TeasersController < ApplicationController
  def show
    @account = Account.find_by_subdomain(request.subdomains.first)
  end
end