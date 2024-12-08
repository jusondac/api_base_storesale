Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :products
      resources :categories
      resources :customers
      resources :orders do
        resources :order_items, only: [:create, :destroy]
      end
      post 'auth/signup', to: 'auth#signup'
      post 'auth/login', to: 'auth#login'
      get 'auth/auto_login', to: 'auth#auto_login'  # Optional
    end
    namespace :v2 do
      resources :stocks, only: [:index, :show, :update]
      resources :restocks, only: [:create]
      resources :suppliers, only: [:index, :create]
      resources :invoices, only: [:index, :show]
      resources :payments, only: [:create]
      resources :employees, only: [:index]
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end
