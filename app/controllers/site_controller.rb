class SiteController < ApplicationController
  helper_method :current_line

  def index
    session[:line_id] ||= Line.last.id
  end

  def change_current_line
    session[:line_id] = params[:line_id]
    redirect_to site_index_url
  end

  private
  def current_line
    Line.find session[:line_id]
  end
end
