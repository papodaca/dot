# == Route Map
#

require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  root "application#index"
  resources :feeds
  devise_for :users

  resources :directories, only: [:show]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  # Almost every application defines a route for the root path ("/") at the top of this file.
  # root "articles#index"

  mount Sidekiq::Web => '/sidekiq'
end
