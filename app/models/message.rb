# encoding: utf-8
# Users can send me messages
class Message < ActiveRecord::Base

  attr_accessible :advertising, :contact_method, :name, :text, :spam_answer

  after_create :pass_on_message

  def pass_on_message
    Delayed::Job.enqueue EmailMessage.new(self.id)
  end

  EmailMessage = Struct.new :message_id do
    def perform
      Emailer.new_message(Message.find(message_id)).deliver
    end
  end
end
