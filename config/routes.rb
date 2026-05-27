Rails.application.routes.draw do
  get "login", to: "sessions#new", as: "login"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: "logout"

  root "sessions#new"
  get "up", to: "rails/health#show", as: "rails_health_check"
end
