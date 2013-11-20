# encoding: utf-8
# Users can send me messages
class Message < ActiveRecord::Base

  attr_accessible :advertising, :contact_method, :name, :text, :spam_answer
end
