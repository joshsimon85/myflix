Myflix::Application.routes.draw do
  get 'ui(/:action)', controller: 'ui'

  root 'pages#front'
  get 'register', to: 'users#new'
  get 'home', to: 'videos#index'
  get 'sign_in', to: 'sessions#new'
  get 'sign_out', to: 'sessions#destroy'
  get 'my_queue', to: 'queue_items#index'
  post 'my_queue', to: 'queue_items#destroy'
  post 'update_queue', to: 'queue_items#update_queue'

  resources :videos, only: :show do
    collection do
      get '/search', to: 'videos#search'
    end

    resources :reviews, only: :create
  end

  resources :queue_items, only: [:create, :destroy]
  resources :categories, only: :show
  resources :sessions, only: :create
  resources :users, only: [:create, :show]
  get '/people', to: 'relationships#index'
  resources :relationships, only: [:create, :destroy]
end
