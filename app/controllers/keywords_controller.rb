# encoding: utf-8
class KeywordsController < AngularController
  before_filter :track, except: [:partials]
  before_filter :authenticate_advertiser!

  def new
    if current_advertiser.wants_js?
      super
    else
      @ad = Ad.find(params[:ad_id])
    end
  end

  def edit
    if current_advertiser.wants_js?
      super
    else
      @ad = Ad.find(params[:ad_id])
      @ad_keyword = AdKeyword.find(params[:id])
    end
  end
  # rubocop:disable MethodLength
  def create
    @ad = Ad.find(params[:ad_id])
    keywords = params[:keywords].map(&:last)
    keywords.delete_if { |k| k[:keyword].empty? && k[:bid].empty? }

    keywords.each do |k|
      ad_keyword = AdKeyword \
        .find_or_initialize_by_ad_id_and_keyword_id(
          @ad.id, Keyword.find_or_create_by_word(k[:keyword]).id
        )
      ad_keyword.bid =  k[:bid]
      ad_keyword.save
      @ad.ad_keywords << ad_keyword
    end
    redirect_to edit_ad_path(@ad)
  end
  # rubocop:enable MethodLength
  def update
    ak = AdKeyword.find(params[:id])
    ak_params = params[:ad_keyword]
    ak_params[:keyword_id] = Keyword.find_by_word(ak_params.delete(:word)).id
    ak.update_attributes(ak_params)
    redirect_to edit_ad_path(params[:ad_id])
  end

  def destroy
    ak = AdKeyword.find(params[:id])
    w = ak.word
    ak.destroy
    flash.notice = "You have deleted the keyword '#{w}'"
    redirect_to edit_ad_path(params[:ad_id])
  end

  def partials
    render "keywords/angular_partials/#{params[:partial]}", layout: false
  end

  private

  def track
    #return true unless Rails.env.include? 'production'

    Tracker.new(request).track_later!
  end
end
