Rails.application.routes.draw do
  
  namespace :admin do
    resources :logs, only: [:index]
  end
  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :users do
        collection do
          get :check_email_existence
          get :generate_fake_identity
          get :generate_secure_password
          get :is_common_password
          get :crawl_person_info
          get :get_person_info
          get :random_image
        end
      end
    end
  end  
end