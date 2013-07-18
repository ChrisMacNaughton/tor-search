class Image < ActiveRecord::Base
  #include ::SolrSearch::Index
  has_many :inbound_links, class_name: "Link", as: :to_target, dependent: :destroy

  belongs_to :domain
  attr_accessible :path, :thumbnail_path, :domain, :image, :alt_text, :domain_id, :disabled
  before_save :manage_duplicates

  has_many :content_flags, as: :content

  has_attached_file :image,
    :styles => { :thumbnail => ["100x100>", :png] },
    :default_url => "/images/:style/missing.png",
    default_style: "thumbnail",
    path: ":rails_root/public/system/images/:id/:style/:filename",
    url: "/images/show/:id/:style"

  searchable(auto_index:false, auto_remove:false) do
    text :alt_text
    text :links do
      inbound_links.map { |link| link.anchor_text }
    end

    double :domain_rank do
      domain.domain_rank
    end
    integer :domain_id
    boolean :disabled
  end

  def url
    p = "#{domain.path}/#{path}".gsub('//','/')
    "http://#{p}"
  end
  def crawl!
    handler      = Crawler.new(url)
    handler.execute
  end
  private
  def manage_duplicates
    unless image.path.nil?
      File.open(image.path) {|i| @hex = Digest::MD5.hexdigest(i.read)}
      unique_hash = @hex

      duplicates = self.class.where(unique_hash: unique_hash).where('id != ?', id).order('created_at asc')
      self.unique_hash = unique_hash

      unless duplicates.empty?
        self.duplicate_id =  duplicates.first.id
      end
    end
  end
end
