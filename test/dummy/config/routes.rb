Rails.application.routes.draw do
  apipie
  resources :users do
    collection { post :create_unnested }
    resources :posts do
      resources :comments
    end
  end
  get 'archive/users/:user_id/comment/:id', :to => 'comments#show'
  get 'archive/comment/:id', :to => 'comments#show'
end
