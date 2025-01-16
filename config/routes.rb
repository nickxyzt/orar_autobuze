Rails.application.routes.draw do
  get 'site/index'
  get 'site/dismiss_button'
  post 'site/change_current_line'
  post 'site/confirm_stop'

  resources :special_days
  resources :stations
  resources :lines
  resources :stops
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "site#index"
end
