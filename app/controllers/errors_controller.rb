# encoding: utf-8
class ErrorsController < ApplicationController

  def error_404
    @nav = false
    @not_found_path = params[:not_found]

    respond_to do |format|
      format.html { render status: 404 } # error_404.haml
    end
  end

  def error_500
    @nav = false
    render status: 500, layout: false
  end
end
