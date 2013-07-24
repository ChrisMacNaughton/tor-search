class Domain < ActiveRecord::Base
  has_many :pages, dependent: :destroy
  has_many :images
  acts_as_textcaptcha bcrypt_salt: "$2a$10$8VWDl/.y0ei0sfU7KfKksO",
                      bcrypt_cost: 5,
                      questions: [
                        {'question' => 'two + 12', 'answers' => '14,fourteen'},
                        {'question' => 'Is a purple box green?', 'answers' => 'no'},
                        {'question' => 'If tomorrow is Saturday, what day is today?', 'answers'=>'friday,today'},
                        {'question' => 'If a duck is black, what kind of bird is it?', 'answers' => 'duck,a duck'},
                        {'question' => 'If a duck is black, what color is it?', 'answers' => 'black'},
                        {'question' => 'What color is the black house?', 'answers' => 'black'}
                      ]

  class PathValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if value.nil?
        record.errors.add attribute, (options[:message] || "cannot be null")
        return
      end
      initial = value.gsub(/^https?:\/\//, '').split('.')

      unless initial[-1] == 'onion'
        record.errors.add attribute, (options[:message] || "(#{value}) is not a valid onion path")
        return
      end
      initial.pop

      unless initial.join('.').length == 16
        record.errors.add attribute, (options[:message] || "(#{value}) is not a valid onion path")
        return
      end
    end
  end
  validates :path, uniqueness: true, path: true

  attr_accessible :path, :robots, :last_robots_check, :last_crawled,
    :missed_attempts, :blocked, :pending, :spam_answer
  attr_writer :skip_textcaptcha
  before_save :trim_url, :validate_path, :check_blocked
  scope :active, where(blocked: false, pending: false)
  scope :pending, where(pending: true)
  def self.valid_path?(domain)
    initial = domain.gsub(/^https?:\/\//, '').split('.')

    return false unless initial[-1] == 'onion'
    initial.pop

    return initial.join('.').length == 16
  end
  def validate_path
    initial = self.path.gsub(/^https?:\/\//, '').split('.')

    return false unless initial[-1] == 'onion'
    initial.pop

    return initial.join('.').length == 16
  end
  def trim_url
    self.path.gsub!(/https?:\/\//, "")

    self.path.gsub!(/\/\z/, '')
  end
  def check_blocked
    if missed_attempts > 10
      blocked = true
    end
  end
  def outbound_links
    pages.map(&:outbound_links)
  end
  def inbound_links
    pages.map(&:inbound_links)
  end
  def indexable?
    !blocked
  end
  def crawl_delay
    if missed_attempts >= 3
      24.hours
    else
      300 * missed_attempts
    end
  end
  def crawl!
    return false if blocked
    if pages.empty?
      Page.create!(domain: self, path: "")
    end
    i=0
    pages.order('coalesce(last_crawled) asc NULLS FIRST').each do |page|
      page.crawl(i.seconds, 3)
      i+= 10
    end
  end
  def robots_txt
    robots unless last_robots_check.nil? || last_robots_check < 24.hours.ago
  end
  def robots_txt=(text)
    self.update_attributes(robots: text, last_robots_check: DateTime.now)
  end
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
