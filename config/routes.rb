  Rails.application.routes.draw do
  root 'sessions#login'
  get 'login', to: 'sessions#login', as: 'login'
  get 'logout', to: 'sessions#logout', as: 'logout'
  get 'auth/spotify/callback', to: 'users#spotify'
  get 'loading', to: 'application#loading'
  resources :users, only: ['show']
  resources :playlists, only: ['show', 'edit', 'destroy', 'destroy_all']

end
