Rails.application.routes.draw do
  get "password_sets/new"
  get "password_sets/update"
  get "home/index"
  root "sessions#new"

  get "login", to: "sessions#new", as: "/"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: "logout"

  get "/home", to: "home#index", as: "home"

  get  'definir-senha/:token', to: 'password_sets#new',    as: 'password_set'
  patch 'definir-senha/:token', to: 'password_sets#update'
end
