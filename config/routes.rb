Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post 'login', to: 'sessions#create'

      # --- Public, read-only ---
      resource :profile, only: [:show]
      resources :skills, only: [:index]
      resources :projects, param: :slug, only: %i[index show]
      resources :experiences, only: [:index]
      resources :education, only: [:index], controller: 'educations'
      post 'contact_messages', to: 'contact_messages#create'
      resources :memory_log_entries, only: %i[index create]

      # --- Admin, JWT-protected ---
      namespace :admin do
        resource :profile, only: %i[show update]
        resources :skills
        resources :projects
        resources :experiences
        resources :education, controller: 'educations'
      end
    end
  end

  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  get 'dashboard', to: 'dashboards#index'

  # Root: show login when unauthenticated, dashboard when signed in
  root to: 'sessions#new'

  # Admin profile (single resource) and generic admin resource views
  namespace :admin, path: '/admin', module: 'web/admin' do
    resource :profile, only: %i[show edit update]

    # Generic admin resource views (simple, read-only for now)
    get ':resource', to: 'resources#index', as: 'resource'
    get ':resource/:id', to: 'resources#show', as: 'resource_item'
  end

  get 'up' => 'rails/health#show', as: :rails_health_check
end
