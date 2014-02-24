# encoding: utf-8
# used to hold sugegsted additions
class Domain < ActiveRecord::Base
  acts_as_textcaptcha(
    bcrypt_salt: '$2a$10$8VWDl/.y0ei0sfU7KfKksO',
    bcrypt_cost: 5,
    questions: TorSearch::Application.config.tor_search.captcha_questions
  )

  DomainAdder = Struct.new :domain do
    def perform
      Rails.logger.debug { "Checking if we can queue #{domain}"}
      Rails.logger.debug { "Checking if the domain is an onion" }
      return unless !!(domain =~ /[2-7a-zA-Z]{16}\.onion/)
      matches = domain.match(/([2-7a-zA-Z]{16}\.onion)/)
      return if matches.nil?
      root_domain = matches[0]
      search = SolrSearch.new("site: #{root_domain}")
      Rails.logger.debug { "Checking if the domain is indexed" }
      return if search.records.count > 0
      Rails.logger.debug { "Checking if the domain is banned" }
      return unless BannedDomain.where(hostname: root_domain).empty?
      Rails.logger.debug { "Checking if the domain is already pending" }
      return unless Domain.where(path: domain).empty? && Domain.where(path: root_domain).empty?
      Rails.logger.debug { "Creating a new domain!" }
      Domain.create!(path: domain, pending: true)
    end
  end

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
    return true if captcha?
    false
  end

  def self.add_later(path)
    Rails.logger.info { "Queuing up #{path} for crawling"}
    Delayed::Job.enqueue DomainAdder.new(path)
    true
  end
end
