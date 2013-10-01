require "#{Rails.root}/lib/matcher/matcher"

class InstantController < ApplicationController
  def new
    term = params[:search]

    matches = Matcher.new(term, request).execute || []
    hash = {meta: {searched: term}, matches: matches}

    render json: hash
  end
end
