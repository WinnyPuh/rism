Rails.application.routes.draw do
  root to: 'organizations#index'

  resources :user_sessions, only: [:create, :destroy]
  delete '/sign_out', to: 'user_sessions#destroy', as: :sign_out
  get '/sign_in', to: 'user_sessions#new', as: :sign_in


  resources :organizations do
    get :autocomplete_organization_name, :on => :collection, as: :autocomplete
  end

  resources :users do
    get :autocomplete_user_name, :on => :collection, as: :autocomplete
  end
  post '/departments/select', to: 'departments#select', as: :departments_select
  put '/departments/paste', to: 'departments#paste', as: :departments_paste
  get '/departments/reset', to: 'departments#reset', as: :departments_reset
  resources :roles
  resources :role_members
  resources :rights
  resources :departments do
    get :autocomplete_department_id, :on => :collection, as: :autocomplete
  end
  resources :agreements do
    get :autocomplete_agreement_prop, :on => :collection, as: :autocomplete
  end
  resources :attachments
  resources :attachment_links
  resources :versions, only: [:index]
  resources :agreement_kinds
  resources :organization_kinds
  post "versions/:id/revert" => "versions#revert", as: :revert_version
  get "/attachments/:id/download", to: "attachments#download", as: :attachment_download
  resources :tag_kinds
  resources :tags
  resources :tag_members, only: %i[create destroy]
  resources :incidents
  resources :link_kinds
  resources :links, only: %i[create destroy]
  resources :record_templates
end
