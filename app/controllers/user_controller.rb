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
    if params[:email] != nil and params[:email].blank?
      redirect_to '/login', alert: 'Endereço de e-mail não informado'
      return
    end

    is_valid_email = (params[:email] =~ URI::MailTo::EMAIL_REGEXP) != nil
    is_blank_email = params[:email].blank?

    unless is_valid_email or params[:email].blank?
      logger.debug "Invalid email: #{params[:email]}"
      redirect_to '/login', alert: 'Endereço de e-mail inválido'
      return
    end

    user = User.find_by(email: params[:email])

    is_blank_password = (params[:password] != nil and params[:password].blank?)

    if is_blank_password
      redirect_to '/login', alert: 'Senha não informada'
      return
    end

    if user && user.authenticate(params[:password])
      redirect_to '/'
    elsif not is_blank_email and not is_blank_password 
      increase_login_attemps(user)
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
  end
end
