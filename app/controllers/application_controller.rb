class ApplicationController < ActionController::Base
  helper_method :site_index_path, :site_index_url

  before_action do 
    session[:user_config_next_reminder] ||= Time.zone.now
    session[:user_config_next_reminder_index] ||= 0
  end

  def site_index_path
    root_path
  end

  def site_index_url
    root_url
  end
end
