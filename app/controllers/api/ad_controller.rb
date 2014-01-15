# encoding: utf-8
class Api::AdController < ApplicationController
  include Base::Behaviors::Angular
  before_filter :authenticate_advertiser!
  #before_filter :track

  def advertiser_balance
    respond_to do |format|
      format.json{ render json: {balance: current_advertiser.balance } }
    end
  end

  def index
    respond_to do |format|
      format.json {
        page = (params[:page] || 1).to_i
        per_page = (params[:per_page] || 20).to_i

        render json: paginated_results_hash(current_advertiser.ads.page(page) \
          .per_page(per_page).order(:created_at).includes(:ad_keywords), {serializer: AdSerializer})
      }
    end
  end

  def show
    respond_to do |format|
      ad = current_advertiser.ads.where(id: params[:id]).try(:first)
      if ad
        format.json {
          render json: ad
        }
      else
        format.json {
          render json: {}, status: 403
        }
      end
    end
  end

  def create
    respond_to do |format|
      format.json {
        ad = {
          title: params[:ad][:title],
          path: params[:ad][:path],
          display_path: params[:ad][:display_path],
          line_1: params[:ad][:line1],
          line_2: params[:ad][:line2],
          bid: params[:ad][:bid]
        }

        ad[:protocol_id] = if params[:ad][:protocol] == 'HTTP'
          0
        else
          1
        end
        if current_advertiser.is_auto_approved?
          ad[:approved] = true
        end
        ad = Ad.new(ad)
        ad.advertiser = current_advertiser
        ad.save
        @mixpanel_tracker.track(current_advertiser.id, 'created an ad', {ad: {id: ad.id, title: ad.title}}, visitor_ip_address)
        render json: ad
      }
    end
  end

  def update
    respond_to do |format|
      format.json {
        ad = current_advertiser.ads.where(id: params[:id]).try(:first)
        render json: {} unless ad
        opts = params[:ad]
        ad_params = {
          title: opts[:title],
          protocol_id: opts[:protocol] == 'HTTP' ? 0 : 1,
          path: opts[:path],
          display_path: opts[:display_path],
          line_1: opts[:line1],
          line_2: opts[:line2],
          disabled: opts[:disabled],
          bid: opts[:bid]
        }.delete_if{|k,v| v.nil?}

        require_approval = [:title, :path, :display_path, :line_1, :line_2]
        approved = ad_params.select{ |k,v| require_approval.include? k.to_sym}.select{|k,v| ad.send(k.to_sym) != v }.empty?
        ad_params[:approved] = false unless approved || current_advertiser.is_auto_approved?

        ad.update_attributes(ad_params)
        @mixpanel_tracker.track(current_advertiser.id, 'updated an ad', {ad: {id: ad.id, title: ad.title}}, visitor_ip_address)
        render json: ad
      }
    end
  end

  private

  def track
    #return true unless Rails.env.include? 'production'

    Tracker.new(request).track_later!
  end

end
