Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  # O redesign removeu o botão de login do header; o acesso ao painel é por URL direta.
  # /login abre o formulário; /admin cai no CRUD (que já redireciona ao login se preciso).
  get "login", to: "sessions#new", as: :login
  get "admin", to: redirect("/admin/posts")

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
