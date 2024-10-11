class ApplicationController < ActionController::API
  include Pundit::Authorization

  def log_action(action, model)
    if current_user
      Rails.logger.info "Action: #{action}, Model: #{model}, User ID: #{current_user.id}"
    else
      Rails.logger.warn "Action: #{action}, Model: #{model}, User is not logged in."
    end
  end
  
end
