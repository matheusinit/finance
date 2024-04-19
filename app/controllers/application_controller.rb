class ApplicationController < ActionController::Base
  before_action :require_login

  def logged_in?
    session[:current_user_id].present?
  end

  helper_method :logged_in?

  def current_path?
    request.original_fullpath
  end

  helper_method :current_path?

  private

  def require_login
    unless logged_in?
      flash[:error] = "Você deve estar autenticado para acessar"
      redirect_to "/login"
    end
  end
end
