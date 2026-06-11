Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  root "posts#index"

  get "search", to: "search#index", as: :search

  namespace :admin do
    resources :posts, param: :slug do
      collection do
        post :preview
      end
    end
  end

  get "posts/:slug", to: "posts#show", as: :post

  get "up" => "rails/health#show", as: :rails_health_check
end
