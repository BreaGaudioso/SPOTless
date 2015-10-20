Rails.application.routes.draw do
  root 'sessions#login'
  get 'login', to: 'sessions#login', as: 'login'
  get 'auth/spotify/callback', to: 'users#index'

end
