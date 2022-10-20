# frozen_string_literal: true

Rails.application.routes.draw do
  resources :user_crud
  resources :category_list
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    passwords: 'users/passwords',
    confirmations: 'users/confirmations'
  }
  root to: 'service_centers#index'
  resources :service_centers do
    collection do
      get 'shop_detail', to: 'service_centers#shop_detail'
      get 'admin', to: 'service_centers#admin'    
      get 'all_shop', to: "service_centers#all_shop"
      get 'shop_list', to: "service_centers#shop_list"
      post "order_pending", to: "service_centers#order_pending"
    end    
    member do
      get 'show_data', to: "service_centers#show_data"
      get 'update_to', to: "service_centers#update_to"
    end
  end
  get 'order/:id/:service_id',to: "clients#order_cancel",as: :order_cancel
  get 'client_request/:id', to: 'service_centers#client_request',as: :client_request
  get 'add_service/:id', to: 'service_centers#add_service', as: :add_service
  get 'request_to_owner/:id', to:'service_centers#request_to_owner',as: :request_to_owner
  post 'order_confirmation/:data/' , to: 'service_centers#order_confirmation',as: :order_confirmation
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")

  get 'payment/:client_id/:cost/:service_center_id', to: 'service_centers#payment', as: 'payment'
  post 'charge', to: 'service_centers#charge', as: 'charge'
  # root "articles#index"
  resources :clients do
    collection do  
      get "user_profile",to: 'clients#user_profile'
      get "admin_path" ,to: "clients#admin"
    end    
    member do 
      get "show_data", to: "clients#show_data"
      get "update_slot", to: "clients#update_slot"
      get "bill_detail", to: "clients#bill_detail"
      get 'revenue',to: "clients#revenue"
    end  

  end
  resources :slot ,except: %i[create edit destroy]
  post 'create/:id', to: 'slot#create'
  get 'edit/:service_id/:slot_id',to: 'slot#edit' ,as: :edit_slot
  get 'delete/:service_id/:slot_id',to: 'slot#edit' ,as: :delete_slot
end




