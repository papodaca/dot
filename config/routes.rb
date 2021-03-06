# == Route Map
#

require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  root "application#index"
  devise_for :users

  resources :feeds
  resources :directories
  resources :articles, only: [:index]

  mount Sidekiq::Web => '/sidekiq'
end
