Drawing::Application.routes.draw do
  root :to => 'pictures#new'
  resources :pictures, :only => [:index, :create]
end
