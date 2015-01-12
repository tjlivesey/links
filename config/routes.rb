Rails.application.routes.draw do

  root to: 'static#home'

  get 'auth/twitter' => 'auth/twitter#auth', as: :twitter_auth
  get 'auth/twitter/callback' => 'auth/twitter#callback', as: :twitter_callback

  get 'auth/facebook' => 'auth/facebook#auth', as: :facebook_auth
  get 'auth/facebook/callback' => 'auth/facebook#callback', as: :facebook_callback

  get 'auth/linkedin' => 'auth/linkedin#auth', as: :linkedin_auth
  get 'auth/linkedin/callback' => 'auth/linkedin#callback', as: :linkedin_callback

  get '/view' => 'links#show', as: :view_link

  resources :links

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
