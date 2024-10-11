class ApplicationController < ActionController::API
  include Pundit::Authorization
  include DeviseTokenAuth::Concerns::User
  include Authenticable
end
