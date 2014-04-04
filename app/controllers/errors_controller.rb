# encoding: utf-8
class ErrorsController < ApplicationController

  def error_404
    render template: 'errors/error_404', status: 404, layout: 'application'
    true
  end

  def error_500
    @nav = false
    render status: 500, layout: false
  end
end
