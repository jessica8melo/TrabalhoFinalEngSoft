Rails.application.routes.draw do
  get "home/index"
  root "sessions#new"

  get "login", to: "sessions#new", as: "login"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: "logout"

  get "/home", to: "home#index", as: "home"
end
