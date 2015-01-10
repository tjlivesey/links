Rails.application.routes.draw do

  root to: 'static#home'

  get 'auth/twitter' => 'auth/twitter#auth', as: :twitter_auth
  get 'auth/twitter/callback' => 'auth/twitter#callback', as: :twitter_callback

  get 'auth/facebook' => 'auth/facebook#auth', as: :facebook_auth
  get 'auth/twitter/facebook' => 'auth/facebook#callback', as: :facebook_callback

  get '/view' => 'links#show', as: :view_link

  resources :links

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
