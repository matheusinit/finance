class UserController < ApplicationController
  def create
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
  end

  def login
    if params[:email] != nil and params[:email].blank?
      redirect_to '/login', alert: 'Endereço de e-mail não informado'
      return
    end

    is_valid_email = (params[:email] =~ URI::MailTo::EMAIL_REGEXP) != nil
    is_blank_email = (params[:email] == nil and params[:email].blank?)

    unless is_valid_email or is_blank_email
      logger.debug "Invalid email: #{params[:email]}"
      redirect_to '/login', alert: 'Endereço de e-mail inválido'
      return
    end

    is_blank_password = (params[:password] != nil and params[:password].blank?)

    if params[:password] != nil and params[:password].blank?
      redirect_to '/login', alert: 'Senha não informada'
      return
    end

    user = User.find_by(email: params[:email])

    if user && user.authenticate(params[:password])
      redirect_to '/'
    elsif not is_blank_email and not is_blank_password 
      redirect_to '/login', alert: 'Credenciais inválidas'
    end
  end
end
