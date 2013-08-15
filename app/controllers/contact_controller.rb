class ContactController < ApplicationController
  def contact
  end
  def new_message
    message = Message.create(params[:message])

    if message.save
      flash.notice = "Thank you, I will try to respond shortly!"
      redirect_to search_path and return
    else
      render :contact
    end
  end
end