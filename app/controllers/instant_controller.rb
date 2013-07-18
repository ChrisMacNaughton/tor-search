require "#{Rails.root}/lib/matcher/matcher"

class InstantController < ApplicationController
  def new
    term = params[:search]

    matches = Matcher.new(term, request).execute || []
    render text: {meta: {searched: term}, matches: matches}.to_json
  end
end
