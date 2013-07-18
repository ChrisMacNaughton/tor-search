require "#{Rails.root}/lib/crawler/crawler"

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

  def self.to_crawl
    Delayed::Job.where(queue: 'crawl').count
  end
  def self.to_parse
    Delayed::Job.where(queue: 'parse').count
  end

  searchable(auto_index:false, auto_remove:false) do
    text :title, stored: true
    text :description, stored: true
    text :body

    #text :body, as: :content_textp

    text :links do
      inbound_links.map { |link| link.anchor_text }
    end
    text :path, stored: true
    text :domain_path, stored: true do
      domain.path
    end
    double :page_rank

    double :domain_rank do
      domain.domain_rank
    end
    boolean :disabled do
      domain.blocked
    end
    integer :domain_id
    integer :links_count do
      inbound_links.count
    end
  end

  before_save :trim_url

  def trim_url
    self.path.gsub!(/\A\//, '')
  end

  def url
    p = "#{domain.path}/#{path}".gsub(/\/{2,}}/,'/')
    "http://#{p}"
  end
  def crawl(delay = 0.seconds, urgency = 0)
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
