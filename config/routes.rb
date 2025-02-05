Rails.application.routes.draw do
  get '/line_schedule/(:id)', to: 'site#line_schedule', as: :site_line_schedule
  get '/station_schedule/(:id)', to: 'site#station_schedule', as: :site_station_schedule
  get 'site/dismiss_button'
  get '/pwa', to: 'site#index', defaults: { pwa_mode: 'pwa' }
  post 'site/change_current_line'
  post 'site/change_current_station'
  post 'site/confirm_stop'
  get  'site/index'

  resources :special_days
  resources :stations
  resources :lines
  resources :stops
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "site#index"
end
