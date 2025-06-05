Rails.application.routes.draw do
  get "profiles/show"
  get "profiles/edit"
  get "profiles/update"
  get "home/index"
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }
  resource :profile, only: [:show, :edit, :update]
  resources :users, only: [:show]

  root "home#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  resources :communities do
    member do
      post :join
      delete :leave
    end
  end

  resources :compliments do
    member do
      post 'kudos', to: 'compliments#add_kudos'
      delete 'kudos', to: 'compliments#remove_kudos'
      post 'report', to: 'compliments#report'
      patch 'read', to: 'compliments#mark_as_read'
    end

    collection do
      get 'recipients', to: 'compliments#recipients'
      get 'categories', to: 'compliments#categories'
    end
  end

  # API routes for Turbo/Stimulus
  namespace :api do
    resources :categories, only: [] do
      member do
        get 'templates'
      end
    end
  end

  # Dashboard route
  get 'dashboard', to: 'dashboard#index'

  # Defines the root path route ("/")
  # root "posts#index"
end
