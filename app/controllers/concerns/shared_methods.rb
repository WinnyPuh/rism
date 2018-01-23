# methods that used both in Organizatiable and DefaultAactions
module SharedMethods
  extend ActiveSupport::Concern

  included do
    before_action :set_edit_previous_page, only: [:new, :edit]
    before_action :set_show_previous_page, only: [:index]
  end

  private

  # show record previous version instead real record if param
  # version_id is set
  def record
    if params[:version_id].present?
      PaperTrail::Version.find(params[:version_id]).reify
    else
      model.find(params[:id])
    end
  end

  def set_show_previous_page
    session[:show_return_to] = request.original_url
  end

  def set_edit_previous_page
    session[:return_to] = request.referer
  end

  # set sort field and direction by default
  # (applies when go to index page from other place)
  def default_sort
    'name asc'
  end
end
