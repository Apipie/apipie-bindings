Rails.application.routes.draw do
  apipie
  resources :users do
    collection { post :create_unnested }
    resources :posts do
      resources :comments
    end
  end
end
