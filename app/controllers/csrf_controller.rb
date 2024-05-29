class CsrfController < ApplicationController
  skip_before_action :require_login, only: [:index]

  def index
    render json: { csrf_token: form_authenticity_token }
  end
end
