Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  root "posts#index"

  get "search", to: "search#index", as: :search

  get "settings", to: "settings#show", as: :settings

  namespace :admin do
    resources :posts, param: :slug do
      collection do
        post :preview
      end
    end
  end

  namespace :api, defaults: { format: :json } do
    resources :posts, only: :index
  end

  get "posts/:slug", to: "posts#show", as: :post

  get "up" => "rails/health#show", as: :rails_health_check
end
