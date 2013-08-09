class Message < ActiveRecord::Base
  attr_accessible :advertising, :contact_method, :name, :text
end
