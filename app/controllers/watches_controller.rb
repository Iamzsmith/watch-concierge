class WatchesController < ApplicationController
  def index
  end

  def create
    @query = params[:query]
    @result = WatchLookupService.new(@query).call
    render :index
  end
end