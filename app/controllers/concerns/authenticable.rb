module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    before_action :authorize_admin, only: [:create, :update, :destroy]
  end

  def authorize_admin
    render json: { error: 'Forbidden' }, status: :forbidden unless current_user.role == 'admin'
  end
end