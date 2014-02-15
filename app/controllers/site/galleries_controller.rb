class Site::GalleriesController < Site::BaseController

  before_filter :redirect_gallery, only: :show
  def index
    @galleries =  Gallery.order('date DESC')
    begin
      custom_page and return
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end

  def show
    @gallery = Gallery.find(params[:id])
    @recent = Gallery.order('created_at DESC').limit(3).reject(&:empty?)
  end

  private
  def redirect_gallery
    @gallery = Gallery.find(params[:id])
    expected_path = url_for(
      id: @gallery,
      controller: controller_path,
      action: action_name,
      only_path: true
    )
    if not social_crawler? and request.path != expected_path
      return redirect_to expected_path, status: :moved_permanently
    end
  end

end
