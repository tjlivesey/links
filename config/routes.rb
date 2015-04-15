Rails.application.routes.draw do

  root to: 'static#home'

  get 'auth/twitter' => 'auth/twitter#auth', as: :twitter_auth
  get 'auth/twitter/callback' => 'auth/twitter#callback', as: :twitter_callback

  get 'auth/:site', to: 'auth/oauth#auth', as: :oauth_authorisation, constraints: { site: /google|linkedin|facebook/ }
  get 'auth/:site/callback', to: 'auth/oauth#callback', as: :oauth_callback, constraints: { site: /google|linkedin|facebook/ }


  resources :links

  namespace :api do
    resources :links, only: [:index, :destroy]
  end

  require 'sidekiq/web'
  require 'sidetiq/web'
  mount Sidekiq::Web => '/sidekiq'

  class Oauth2Constraint

    def self.matches?(request)

    end

  end
end
