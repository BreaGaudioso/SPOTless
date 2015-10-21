Rails.application.routes.draw do
  root 'sessions#login'
  get 'login', to: 'sessions#login', as: 'login'
  get 'logout', to: 'sessions#logout', as: 'logout'
  get 'auth/spotify/callback', to: 'users#spotify'
  resources :users, only: ['index']
  resources :playlists, only: ['show', 'edit', 'destroy']
end
