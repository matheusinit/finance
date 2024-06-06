class UserController < ApplicationController
  skip_before_action :require_login, only: [:create, :login]
  skip_before_action :verify_authenticity_token 


  def create
    if params[:name] == nil or params[:email] == nil or params[:password] == nil
      return
    end

    if params[:password] != params[:password_confirmation]
      redirect_to "/user/new", alert: "Passwords do not match"
      return
    end

    ActiveRecord::Base.transaction do
      user = User.new
      user.id = SecureRandom.uuid
      user.name = params[:name]
      user.email = params[:email]
      user.password = params[:password]

      user.save!

      account = Account.new
      account.id = SecureRandom.uuid
      account.user_id = user.id

      account.save!
    end
  end

  def login
    is_email_blank = params[:email].blank?
    is_email_nil = params[:email] == nil

    if !is_email_nil and is_email_blank
      redirect_to "/login", alert: "Endereço de e-mail não informado"
      return
    end

    is_valid_email = (params[:email] =~ URI::MailTo::EMAIL_REGEXP) != nil

    unless is_valid_email or is_email_blank
      redirect_to "/login", alert: "Endereço de e-mail inválido"
      return
    end

    is_password_blank = (params[:password] != nil and params[:password].blank?)

    if is_password_blank
      redirect_to "/login", alert: "Senha não informada"
      return
    end

    user = User.find_by(email: params[:email])

    account = user ? Account.find_by(user_id: user.id) : nil

    if user && user.authenticate(params[:password])
      session[:current_user_id] = user.id
      redirect_to "/receipt"
    elsif not is_email_blank and not is_password_blank
      login_block_time = 10.minutes

      if account and account.updated_at <= login_block_time.ago
        reset_login_attempts(user)
      end

      if user
        increase_login_attemps(user)
        login_is_blocked = is_login_blocked?(user)
      end

      if login_is_blocked
        redirect_to "/login", alert: "Muitas tentativas de login, o seu usuario foi bloqueado por 10 minutos. Tente novamente em breve."
        return
      end

      redirect_to "/login", alert: "Credenciais inválidas"
    end
  end

  def destroy_session
    session.delete(:current_user_id)

    redirect_to "/login"
  end

  private

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
end
