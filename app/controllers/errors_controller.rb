# encoding: utf-8
class ErrorsController < ApplicationController

  def error_404
    @not_found_path = params[:not_found]

    respond_to do |format|
      format.html { render status: 404 } # error_404.haml
    end
  end

  def error_500
    @force_category_banner = '500 Internal Server Error'
    render status: 500
  end
end
