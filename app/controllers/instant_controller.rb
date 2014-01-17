# encoding: utf-8
require "#{Rails.root}/lib/matcher/matcher"

class InstantController < ApplicationController
  def new
    if params[:search]
      term = params[:search]

      matches = Matcher.new(term, request).execute || []
      hash = { meta: { searched: term }, matches: matches }

      render json: hash
    else
      redirect_to root_path
    end
  end
end
