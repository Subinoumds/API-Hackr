class Admin::LogsController < ApplicationController
  before_action :authenticate_admin!

  def index
    @logs = Log.all 
  end

  private

  def authenticate_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: 'Accès refusé. Vous devez être un administrateur pour accéder à cette page.'
    end
  end
end
