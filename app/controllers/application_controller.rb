class ApplicationController < ActionController::Base
  before_action :require_login

  private

  def require_login
    unless logged_in?
      flash[:error] = "Você deve estar autenticado para acessar"
      redirect_to '/login'
    end
  end

  def logged_in?
    session[:current_user_id].present?
  end
end
