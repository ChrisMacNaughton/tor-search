class KeywordsController < ApplicationController
  before_filter :track

  def new
    @ad = Ad.find(params[:id])
  end
end
