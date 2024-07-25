class UserController < ApplicationController
  skip_before_action :require_login, only: [:create, :login, :new]

  def create
    ActiveRecord::Base.transaction do
      @user = User.new(user_params)

      if @user.save
        account = Account.new(
          :user_id => @user.id,
        )

        account.save!

        redirect_to login_path
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def new
    @user = User.new
  end

  def login_api
    verify_authentication_credentials(params[:email], params[:password])

    is_email_blank = params[:email].blank?
    is_password_blank = (params[:password] != nil and params[:password].blank?)

    user = User.find_by(email: params[:email])
    account = user ? Account.find_by(user_id: user.id) : nil

    if user && user.authenticate(params[:password])
      session[:current_user_id] = user.id
      head :ok
    elsif not is_email_blank and not is_password_blank
      login_is_blocked = count_attemps_and_block_at_limit(user, account)

      if login_is_blocked
        head :forbidden
      end

      head :unauthorized
    end
  rescue ActionController::ParameterMissing => _error
    head :bad_request
  end

  def login
    verify_authentication_credentials(params[:email], params[:password])

    is_email_blank = params[:email].blank?
    is_password_blank = (params[:password] != nil and params[:password].blank?)

    user = User.find_by(email: params[:email])
    account = user ? Account.find_by(user_id: user.id) : nil

    if user && user.authenticate(params[:password])
      session[:current_user_id] = user.id
      redirect_to receipt_list_path
    elsif not is_email_blank and not is_password_blank
      login_is_blocked = count_attemps_and_block_at_limit(user, account)

      if login_is_blocked
        redirect_to login_path, alert: "Muitas tentativas de login, o seu usuario foi bloqueado por 10 minutos. Tente novamente em breve."
        return
      end

      redirect_to login_path, alert: "Credenciais inválidas"
    end
  rescue ActionController::ParameterMissing => error
    redirect_to login_path, alert: error.message
  end

  def destroy_session
    session.delete(:current_user_id)

    redirect_to login_path
  end

  private

  def verify_authentication_credentials(email, password)
    is_email_blank = params[:email].blank?
    is_email_nil = params[:email] == nil

    if !is_email_nil and is_email_blank
      raise ActionController::ParameterMissing("Endereço de e-mail não informado")
    end

    is_valid_email = (params[:email] =~ URI::MailTo::EMAIL_REGEXP) != nil

    unless is_valid_email or is_email_blank
      raise ActionController::ParameterMissing("Endereço de e-mail inválido")
    end

    is_password_blank = (params[:password] != nil and params[:password].blank?)

    if is_password_blank
      raise ActionController::ParameterMissing("Senha não informada")
    end
  end

  def count_attemps_and_block_at_limit(user, account)
    login_block_time = 10.minutes

    if account and account.updated_at <= login_block_time.ago
      reset_login_attempts(user)
    end

    if user
      increase_login_attemps(user)
      login_is_blocked = is_login_blocked?(user)
    end

    login_is_blocked
  end

  def increase_login_attemps(user)
    unless user.is_a?(User)
      raise ArgumentError.new("Object user must be of Class User")
    end

    account = Account.find_by(user_id: user.id)
    account.increment!(:login_attempts)

    maximum_login_attempts = 3

    if account.login_attempts <= maximum_login_attempts
      account.touch
    end
  end

  def is_login_blocked?(user)
    unless user.is_a?(User)
      raise ArgumentError.new("Object user must be of Class User")
    end

    login_block_time = 10.minutes

    account = Account.find_by(user_id: user.id)
    account.updated_at > login_block_time.ago

    maximum_login_attempts = 3

    return account && account.login_attempts >= maximum_login_attempts && account.updated_at > login_block_time.ago
  end

  def reset_login_attempts(user)
    unless user.is_a?(User)
      raise ArgumentError.new("Object user must be of Class User")
    end

    account = Account.find_by(user_id: user.id)
    account.login_attempts = 0
    account.save
  end

  def user_params
    params.permit(:name, :email, :password, :password_confirmation)
  end
end
