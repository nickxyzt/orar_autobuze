class ApplicationController < ActionController::Base
  before_action do 
    session[:user_config_next_reminder] ||= Time.zone.now
    session[:user_config_next_reminder_index] ||= 0
  end
end
