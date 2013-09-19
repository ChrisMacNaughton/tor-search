class Domain < ActiveRecord::Base
  acts_as_textcaptcha bcrypt_salt: "$2a$10$8VWDl/.y0ei0sfU7KfKksO",
                      bcrypt_cost: 5,
                      questions: TorSearch::Application.config.tor_search.captcha_questions

  attr_accessible :path, :pending, :spam_answer
  attr_writer :skip_textcaptcha
  scope :active, where(blocked: false, pending: false)
  scope :pending, where(pending: true)

  def use_captcha!
    @captcha = true
  end
  def captcha?
    @captcha ||= false
  end
  def perform_textcaptcha?
    unless captcha?
      return false
    end
    true
  end
end
