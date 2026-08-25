class WatchesController < ApplicationController
  def index
    @result = flash[:result]
  end

  def create
    @query = params[:query]
    result = WatchLookupService.new(@query).call
    redirect_to root_path(query: @query), flash: { result: result }
  end
end