class ApplicationController < ActionController::Base
  helper_method :site_index_path, :site_index_url

  # cached, disponibil in toata aplicatia
  class_attribute :special_days

  before_action do 
    session[:user_config_next_reminder] ||= Time.zone.now
    session[:user_config_next_reminder_index] ||= 0
    self.special_days ||= set_special_days
  end

  def set_special_days
    ApplicationController.special_days = SpecialDay.order(:day).to_a
  end

  def site_index_path
    root_path
  end

  def site_index_url
    root_url
  end
end
