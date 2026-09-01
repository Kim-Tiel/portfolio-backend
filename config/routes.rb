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
        resource :profile, only: %i[show update] do
          put :avatar, to: 'profiles#update_avatar'
          delete :avatar, to: 'profiles#destroy_avatar'
        end
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

  get   'forgot_password',      to: 'password_resets#new', as: 'new_password_reset'
  post  'forgot_password',      to: 'password_resets#create'
  get   'forgot_password/edit', to: 'password_resets#edit', as: 'edit_password_reset'
  patch 'forgot_password/edit', to: 'password_resets#update'

  get 'dashboard', to: 'dashboards#index'

  # Root: show login when unauthenticated, dashboard when signed in
  root to: 'sessions#new'

  # Admin profile (single resource) and generic admin resource views
  namespace :admin, path: '/admin', module: 'web/admin' do
    resource :profile, only: %i[show edit update]
    get 'skills/new', to: 'skills#new', as: 'new_skill'
    get 'skills/:id/edit', to: 'skills#edit', as: 'edit_skill'
    resources :skills, except: %i[new edit]
    get 'projects/new', to: 'projects#new', as: 'new_project'
    get 'projects/:id/edit', to: 'projects#edit', as: 'edit_project'
    resources :projects, except: %i[new edit]
    get 'experiences/new', to: 'experiences#new', as: 'new_experience'
    get 'experiences/:id/edit', to: 'experiences#edit', as: 'edit_experience'
    resources :experiences, except: %i[new edit]
    get 'educations/new', to: 'educations#new', as: 'new_education'
    get 'educations/:id/edit', to: 'educations#edit', as: 'edit_education'
    resources :educations, except: %i[new edit]
    resources :contact_messages, only: %i[index show destroy], controller: 'contact_messages'
    resources :admins, only: %i[index show]
    post 'memory_log_entries/:id/approve', to: 'memory_log_entries#approve', as: 'approve_memory_log_entry'
    resources :memory_log_entries, path: 'memory_log_entries', only: %i[index show destroy]

    # Generic admin resource views (simple, read-only for now)
    get ':resource', to: 'resources#index', as: 'resource'
    get ':resource/:id', to: 'resources#show', as: 'resource_item'
  end

  get 'up' => 'rails/health#show', as: :rails_health_check
end
