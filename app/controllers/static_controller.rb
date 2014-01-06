# encoding: utf-8
class StaticController < ApplicationController
  def policies
    track
  end

  def humans
    track
    render 'humans.txt', layout: false, content_type: 'text/plain'
  end
end
