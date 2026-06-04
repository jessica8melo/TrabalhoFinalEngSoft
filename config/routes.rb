Rails.application.routes.draw do
  root "sessions#new"
  
  get "home/index"

  get "login", to: "sessions#new", as: "/"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: "logout"

  get "/home", to: "home#index", as: "home"

  get  'definir-senha/:token', to: 'password_sets#new',    as: 'password_set'
  patch 'definir-senha/:token', to: 'password_sets#update'

  namespace :admin do
    resources :imports, only: [:index, :create]
  end

  get   "esqueci-senha",          to: "password_resets#new",    as: "new_password_reset"
  post  "esqueci-senha",          to: "password_resets#create", as: "password_resets"
  get   "redefinir-senha/:token", to: "password_resets#edit",   as: "password_reset"
  patch "redefinir-senha/:token", to: "password_resets#update"
end
