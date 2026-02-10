Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "posts#index"

  # Posts resources with nested comments and likes
  resources :posts do
    resources :comments, only: [ :create, :destroy ]
    resources :likes, only: [ :create, :destroy ]
  end

  # デザインシステムのコンポーネント一覧（開発環境のみ）
  if Rails.env.development?
    get "/design_system", to: "design_system#index", as: :design_system
    get "/design_system/alerts", to: "design_system#alerts", as: :design_system_alerts
    get "/design_system/buttons", to: "design_system#buttons", as: :design_system_buttons
    get "/design_system/cards", to: "design_system#cards", as: :design_system_cards
    get "/design_system/form_fields", to: "design_system#form_fields", as: :design_system_form_fields
    get "/design_system/typography", to: "design_system#typography", as: :design_system_typography
    get "/design_system/tokens", to: "design_system#tokens", as: :design_system_tokens
  end
end
