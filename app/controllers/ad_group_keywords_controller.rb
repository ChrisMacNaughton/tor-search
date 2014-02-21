# encoding: utf-8
class AdGroupKeywordsController < AdsCommonController

  def index
    page = (params[:page] || 1).to_i
    per_page = 5
    if params[:ad_group_id]
      @ad_group = current_advertiser.ad_groups.where(id: params[:ad_group_id]).first
      @campaign = @ad_group.ad_campaign
    elsif params[:ad_group_id].nil? && params[:campaign_id]
      @campaign = current_advertiser.ad_campaigns.where(id: params[:campaign_id]).first
    end

    keywords = current_advertiser.ad_group_keywords

    keywords = keywords.where(ad_group_id: @ad_group.id) if @ad_group
    if @ad_group.nil? && @campaign
      ad_group_ids = @campaign.ad_groups.pluck(:id)
      keywords = keywords.where(ad_group_id: ad_group_ids)
    end

    @keywords = keywords.joins(:keyword).order(:word).page(page).per_page(per_page)
  end

  def edit
    @keyword = current_advertiser.ad_group_keywords.where(id: params[:id]).first
  end

  def update
    @keyword = current_advertiser.ad_group_keywords.where(id: params[:id]).first
    word = params[:ad_group_keyword][:keyword].strip
    key = Keyword.find_or_create_by_word(word)
    @keyword.keyword_id = key.id
    @keyword.bid = params[:ad_group_keyword][:bid]
    existing_keywords = current_advertiser \
        .ad_group_keywords \
        .where(keyword_id: key.id, ad_group_id: @keyword.ad_group_id) \
        .where( 'ad_group_keywords.id <> ?', @keyword.id)

    if existing_keywords.any?
      flash.alert = "You already have this keyword on this ad group"
      redirect_to :back and return
    end
    if @keyword.save
      @mixpanel_tracker.track(current_advertiser.id, 'toggled a keyword', {keyword: {id: @keyword.id, title: word}}, visitor_ip_address)
      flash.notice = 'Keyword Updated'
      redirect_to ad_group_keywords_path(@keyword.ad_group_id) and return
    else
      flash.alert = 'There was a problem, please try again!'
      render :edit
    end
  end

  def new
    @ad_group = current_advertiser.ad_groups.where(id: params[:ad_group_id]).first if params[:ad_group_id]
  end

  def create
    if  params[:ad_group_id].nil? && (params[:ad_group].nil? || params[:ad_group][:id].nil?)
      flash[:alert] = "You must select an ad group"
      redirect_to new_keyword_path and return
    end
    ad_group = current_advertiser.ad_groups.where(id: (params[:ad_group_id] || params[:ad_group][:id])).first
    if ad_group.nil?
      flash[:alert] = "There was a problem handling your request, please try again"
      redirect_to new_keyword_path and return
    end
    if params[:keywords].is_a? String
      keywords = params[:keywords].split(/\n/)
      if keywords.count == 1
        keywords = params[:keywords].split(/,/)
      end
      @keywords = []
      keywords.map do |k|
        word = k.strip
        keyword = Keyword.find_or_create_by_word(word)
        @keywords << AdGroupKeyword.new(ad_group_id: ad_group.id, keyword_id: keyword.id, bid: ad_group.ad_campaign.default_bid || 0.0001)
      end
      render :new
    else
      params[:keyword].each do |k, bid|
        word = k.strip
        keyword = Keyword.find_or_create_by_word(word)
        AdGroupKeyword.create(ad_group_id: params[:ad_group_id], keyword_id: keyword.id, bid: bid)
      end
      redirect_to ad_group_keywords_path(ad_group) and return
    end
  end

  def delete
    keyword = current_advertiser.ad_group_keywords.where(id: params[:keyword_id]).first
    kw = keyword.keyword.word
    if keyword.destroy
      flash.notice = "Successfully removed #{kw}"
    else
      flash.alert = "Something went wrong, please try again later"
    end
    redirect_to :back
  end

  def toggle
    keyword = current_advertiser.ad_group_keywords.where(id: params[:id] || params[:keyword_id]).first
    if keyword.nil?
      flash.alert = 'There was a problem, try again soon!'
      redirect_to :back
    end
    keyword.paused = !keyword.paused
    if keyword.save
      @mixpanel_tracker.track(current_advertiser.id, 'toggled a keyword', {keyword: {id: keyword.id, title: keyword.keyword.word}}, visitor_ip_address)
      flash.notice = 'Keyword Toggled'
    else
      flash.alert = 'There was a problem, try again soon!'
    end
    redirect_to :back
  end
end