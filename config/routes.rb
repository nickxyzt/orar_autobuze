Rails.application.routes.draw do
  resources :special_days
  resources :stations
  resources :lines
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
