class UserController < ApplicationController
  def create
    if params[:name] == nil or params[:email] == nil or params[:password] == nil
      return
    end

    if params[:password] != params[:password_confirmation]
      redirect_to '/user/new', alert: 'Passwords do not match'
      return
    end

    user = User.new
    user.id = SecureRandom.uuid
    user.name = params[:name]
    user.email = params[:email]
    user.password = params[:password]

    user.save

    account = Account.new
    account.id = SecureRandom.uuid
    account.user_id = user.id

    account.save
  end

  def login
    is_email_blank = params[:email].blank?

    if params[:email] != nil and is_email_blank
      redirect_to '/login', alert: 'Endereço de e-mail não informado'
      return
    end

    is_valid_email = (params[:email] =~ URI::MailTo::EMAIL_REGEXP) != nil

    unless is_valid_email or is_email_blank
      redirect_to '/login', alert: 'Endereço de e-mail inválido'
      return
    end

    is_password_blank = (params[:password] != nil and params[:password].blank?)

    if is_password_blank
      redirect_to '/login', alert: 'Senha não informada'
      return
    end

    user = User.find_by(email: params[:email])

    account = user ? Account.find_by(user_id: user.id) : nil

    if user && user.authenticate(params[:password])
      redirect_to '/'
    elsif not is_email_blank and not is_password_blank
      if account and account.updated_at <= 10.minutes.ago
        reset_login_attempts(user)
      end

      increase_login_attemps(user)
      login_is_blocked = is_login_blocked?(user)

      if login_is_blocked
        redirect_to '/login', alert: 'Muitas tentativas de login, o seu usuario foi bloqueado por 10 minutos. Tente novamente em breve.'
        return
      end

      redirect_to '/login', alert: 'Credenciais inválidas'
    end
  end

  private

  def increase_login_attemps(user)
    unless user.is_a?(User)
      raise ArgumentError.new("Object user must be of Class User")
    end

    account = Account.find_by(user_id: user.id)
    account.increment!(:login_attempts)
    if account.login_attempts <= 3
      account.touch
    end
  end

  def is_login_blocked?(user)
    unless user.is_a?(User)
      raise ArgumentError.new("Object user must be of Class User")
    end

    account = Account.find_by(user_id: user.id)
    account.updated_at > 10.minutes.ago

    if account && account.login_attempts >= 3 and account.updated_at > 10.minutes.ago
      return true
    end

    return false
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
