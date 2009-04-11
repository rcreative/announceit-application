class TemplatesController < ApplicationController
  def styles
    render :text => Template.find(params[:id]).styles, :content_type => 'text/css'
  end
end