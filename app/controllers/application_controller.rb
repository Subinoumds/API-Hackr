class ApplicationController < ActionController::API
  include Pundit::Authorization
  include DeviseTokenAuth::Concerns::User
  include Authenticable

  def log_action(action, feature)
    ApiLog.create(action: action, user_id: current_user.id, feature: feature)
  end
end
