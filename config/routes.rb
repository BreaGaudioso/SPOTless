  Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  root 'sessions#login'
  get 'login', to: 'sessions#login', as: 'login'
  get 'logout', to: 'sessions#logout', as: 'logout'
  get 'auth/spotify/callback', to: 'users#spotify'
  get 'loading', to: 'application#loading'
  resources :users, only: ['show', 'destroy']
  resources :playlists, only: ['show', 'edit', 'destroy']
  resources :tracks, only:['show', 'destroy']
end
