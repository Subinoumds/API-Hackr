Rails.application.routes.draw do
  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :users do
        collection do
          get :check_email_existence
          get :generate_fake_identity
          get :generate_secure_password
        end
      end
    end
  end  
end