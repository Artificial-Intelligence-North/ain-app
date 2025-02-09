Rails.application.routes.draw do
  
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  # user sessions
  devise_for :users

  namespace :api do
    scope '(v1)', module: :v1 do
      resources :completions, only: %i[index show create update destroy]
      resources :chats, only: %i[index show create update destroy] do
        resources :messages, only: %i[index show create update destroy]
      end
    end
  end

  resources :chats do
    resources :messages
  end
end
