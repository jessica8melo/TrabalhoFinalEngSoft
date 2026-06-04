class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  before_action :require_login

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
  helper_method :current_user

  def require_login
    redirect_to login_path, alert: "Faça login para continuar." unless current_user
  end

  def admin?
    current_user&.role == "admin"
  end
  helper_method :admin?

  def require_admin
    redirect_to home_path, alert: "Você não tem permissão para acessar esta página." unless admin?
  end
end
