Myflix::Application.routes.draw do
  get 'ui(/:action)', controller: 'ui'

  root 'pages#front'
  get 'register', to: 'users#new'
  get 'home', to: 'videos#index'
  get 'sign_in', to: 'sessions#new'
  get 'sign_out', to: 'sessions#destroy'
  get 'forgot_password', to: 'forgot_passwords#new'
  get 'forgot_password_confirmation', to: 'forgot_passwords#confirm'
  get 'my_queue', to: 'queue_items#index'
  post 'my_queue', to: 'queue_items#destroy'
  post 'update_queue', to: 'queue_items#update_queue'
  get 'expired_token', to: 'pages#expired_token'
  get 'register/:token', to: 'users#new_with_invitation_token', as: 'register_with_token'

  resources :videos, only: :show do
    collection do
      get '/search', to: 'videos#search'
    end

    resources :reviews, only: :create
  end

  namespace :admin do
    resources :videos, only: [:new, :create]
    resources :payments, only: :index
  end

  resources :invitations, only: [:new, :create]
  resources :password_resets, only: [:show, :create]
  resources :forgot_passwords, only: :create
  resources :queue_items, only: [:create, :destroy]
  resources :categories, only: :show
  resources :sessions, only: :create
  resources :users, only: [:create, :show]

  get '/people', to: 'relationships#index'

  resources :relationships, only: [:create, :destroy]

  mount StripeEvent::Engine, at: '/stripe_events'
end
