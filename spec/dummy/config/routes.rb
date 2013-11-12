Dummy::Application.routes.draw do
  match 'testing', :to => 'testing#redirect', :constraints => { :id => /[A-Z]\d{5}/ }, :via => [:get, :post]
  match '*tests', :controller => 'testing', :action => 'index', :via => [:get, :post]

  resources :users, :only => [ :index, :show, :create ] do
    resources :albums, :only => [ :index, :show, :create, :update, :destroy ] do
      resources :images, :only => [ :index, :show, :create, :update, :destroy ]
    end
  end

  namespace :v1 do
    resource :users, :only => [ :index, :show, :create ]
  end

  resources :images
end
