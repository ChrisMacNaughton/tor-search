class Message < ActiveRecord::Base

  acts_as_textcaptcha bcrypt_salt: "$2a$10$8VWDl/.y0ei0sfU7KfKksO",
                      bcrypt_cost: 5,
                      questions: TorSearch::Application.config.tor_search.captcha_questions

  attr_accessible :advertising, :contact_method, :name, :text, :spam_answer
end
