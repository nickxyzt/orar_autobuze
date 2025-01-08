Rails.application.routes.draw do
  get 'site/index'
  post 'site/change_current_line'
  resources :special_days
  resources :stations
  resources :lines
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "site#index"
end
