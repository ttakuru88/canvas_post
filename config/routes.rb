Drawing::Application.routes.draw do
  root :to => 'pictures#index'
  resources :pictures, :only => [:create]
end
