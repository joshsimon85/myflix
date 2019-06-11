Myflix::Application.routes.draw do
  get 'ui(/:action)', controller: 'ui'

  root 'pages#front'
  get 'register', to: 'users#new'
  get 'home', to: 'videos#index'
  get 'sign_in', to: 'sessions#new'
  get 'sign_out', to: 'sessions#destroy'

  resources :videos, only: :show do
    collection do
      get '/search', to: 'videos#search'
    end
  end

  resources :categories, only: :show
  resources :sessions, only: :create
  resources :users, only: :create
end
