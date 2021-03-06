Rails.application.routes.draw do
  	namespace :api do
  		namespace :v1 do
	  		resources :batches, only: [:index, :show, :create, :update] 
			get '/batches/:id/orders', to: 'batches#orders'
	  		resources :orders, only: [:index, :show, :create, :update]
	 	 	resources :reports, only: [:index]
		end
	end
end
