# encoding: utf-8
class Api::KeywordController < ApplicationController
  include Base::Behaviors::Angular
  before_filter :authenticate_advertiser!
  before_filter :track

  def index
    respond_to do |format|
      format.json {
        page = (params[:page] || 1).to_i
        per_page = (params[:per_page] || 10).to_i
        render json: paginated_results_hash(AdKeyword.where(ads: {advertiser_id: current_advertiser.id}).joins(:ad).page(page) \
          .per_page(per_page).order('created_at desc'), {serializer: AdKeywordSerializer})
      }
    end
  end

  def show
    respond_to do |format|
      format.json {
        page = (params[:page] || 1).to_i
        per_page = (params[:per_page] || 10).to_i
        render json: AdKeywordSerializer.new(current_advertiser.ad_keywords.where(id: params[:id]).first)
      }
    end
  end

  def create
    ad = Ad.where(id: params[:keyword][:ad_id], advertiser_id: current_advertiser.id).first
    words = ad.keywords.map(&:word)

    keywords = params[:keyword][:keywords].split("\n").map(&:downcase).uniq

    keywords.each do |word|
      unless words.include? word
        ad_keyword = AdKeyword.create(bid: 0.0, ad: ad, keyword: Keyword.find_or_create_by_word(word))
      end

    end

    render json: {status: "OK"}
  end

  def update
    ad_keyword = AdKeyword.where(id: params[:id], ads: {advertiser_id: current_advertiser.id}).joins(:ad)

    keyword = Keyword.find_or_create_by_word(params[:keyword][:word])

    ad_keyword.keyword = keyword

    ad_keyword.bid = params[:keyword][:bid]
    ad_keyword.save

    render json: AdKeywordSerializer.new(ad_keyword)
  end

  def destroy
    keyword = AdKeyword.where(id: params[:id], ads: {advertiser_id: current_advertiser.id}).joins(:ad).first

    if keyword.destroy
      render json: {status: "OK"}
    else
      render json: {error: keyword.errors}
    end
  end

  private

  def track
    #return true unless Rails.env.include? 'production'

    Tracker.new(request).track_later!
  end

end
