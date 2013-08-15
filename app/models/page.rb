#require "#{Rails.root}/lib/crawler/crawler"

class Page < ActiveRecord::Base
  #include ::SolrSearch::Index

  belongs_to :domain
  has_many :inbound_links, class_name: "Link", as: :to_target, dependent: :destroy
  has_many :outbound_links, class_name: "Link", as: :from_target, dependent: :destroy

  has_many :content_flags, as: :content

  has_many :crawler_log_entries

  has_many :duplicates, class_name: "Page", foreign_key: 'duplicate_id'

  belongs_to :master_page, class_name: "Page"

  has_one :raw_content
  validates :domain_id, presence: true
  validates :path, uniqueness: {scope: :domain_id}
  attr_accessible :domain, :path, :title, :description, :meta_keywords,
    :meta_generator, :body, :last_crawled, :no_crawl, :domain_id

  scope :indexed, where("title IS NOT null and body IS NOT null and body != ''")

  scope :crawled, where('last_crawled IS NOT null')

  before_save :manage_duplicates
  def self.crawl
    sql = "select 'http://' || domains.path || '/' || pages.path as url from domains inner join pages on domains.id = pages.domain_id where domains.blocked = false and domains.id != 654 and pages.description is null order by random()"

    Page.connection.execute(sql).each_row do |row|
      return unless Delayed::Job.where("handler ilike '%#{row[0]}%'").first.nil?
      url = row[0]
      Page.connection.execute("insert into delayed_jobs(priority, attempts, handler, run_at, created_at, updated_at) values (5, 0, '--- !ruby/object:Crawler\nurl: #{url}\n', now(), now(), now())")
    end
  end
  def self.to_crawl
    Delayed::Job.where(queue: 'crawl').count
  end
  def self.to_parse
    Delayed::Job.where(queue: 'parse').count
  end

  searchable(auto_index:false, auto_remove:false) do
    text :title, stored: true, as: :title
    text :content, stored: true, as: :content
    text :url, stored: true, as: :url

    #text :body, as: :content_textp

    text :anchor, stored: true

    double :boost, stored: true
  end

  before_save :trim_url

  def trim_url
    self.path.gsub!(/\A\//, '')
  end

  def url
    p = "#{domain.path}/#{path}".gsub(/\/{2,}}/,'/')
    "http://#{p}".gsub(/\/\.\//, '/')
  end
  def crawl(delay = 0.seconds, urgency = 5)
    return false if domain.blocked
    handler      = Crawler.new(url)
    handler_hash = Digest::MD5.hexdigest(handler.to_yaml)

    Delayed::Job.enqueue(handler, run_at: DateTime.now + delay, priority: urgency) \
      if Delayed::Job.where(handler: handler_hash).empty?
  end
  def crawl!
    handler      = Crawler.new(url)
    handler.execute
  end
  private
  def manage_duplicates
    unless body.nil?
      unique_hash = Digest::MD5.hexdigest(body)

      duplicates = self.class.where(unique_hash: unique_hash).where('id != ?', id).order('created_at asc')
      self.unique_hash = unique_hash

      unless duplicates.empty?
        self.duplicate_id =  duplicates.first.id
      end
    end
  end
end
