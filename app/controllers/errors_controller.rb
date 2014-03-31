# encoding: utf-8
class ErrorsController < ApplicationController

  def error_404
    respond_to do |format|
      @layout = false
      format.html { render template: 'errors/error_404', status: 404, layout: 'application' }
      format.all { render nothing: true, status: 404 }
    end
    true
  end

  def error_500
    @nav = false
    render status: 500, layout: false
  end
end
