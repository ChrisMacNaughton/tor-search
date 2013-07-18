class ImageController < ApplicationController
  def index
    if params[:q]
      search
    else
      @total_images_found = Image.count
      render :index
    end
  end
  def search
    @search_term = params[:q]

    page = params[:page] || 1

    term = @search_term
    @search = Image.search {

      fulltext term do
        boost_fields links: 10
        phrase_slop 2
        query_phrase_slop 2
        with :disabled, false
      end
      paginate :page => params[:page], :per_page => 30
    }

    s = Search.create(query: "!index #{params[:q]}", results_count: @search.total)
    @search_id = s.id
    render 'search'
  end
  def show
    @image = Image.find(params[:id])
    @style = params[:style] || 'medium'
    data = if @image.image.path.nil?
      Net::HTTP.get URI.parse 'http://placehold.it/100x100'
    else
      File.open(@image.image.path(@style)).read
    end
    send_data data, :type => 'image/png',:disposition => 'inline'
  end
  def list
    @images = Image.where('image_file_name is not null').where(disabled: false).order('id asc').page(params[:page] || 1).per_page(50)
  end
  def flag
    session[:refer] = request.referer
    @image = Image.find(params[:id])
    @flag = ContentFlag.new(content: Image.find(params[:id]))
  end
  def complete_flag
    image = Image.find(params[:post][:content_id])
    reason = FlagReason.where(id: params[:flag_reason]).first
    flag = ContentFlag.create(content: image, reason: params[:post][:reason], flag_reason: reason)
    flash.notice = "Thank you for your flag!"
    refer = session[:refer] || root_path
    session[:refer] = nil
    redirect_to refer
  end
end
