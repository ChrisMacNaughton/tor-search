class Emailer < ActionMailer::Base
  default from: "support@torsearch.es"

  def new_message(message_id)
    @message = Message.find(message_id)
    mail(to: 'chris@torsearch.es', subject: 'A message was received')
  end
end
