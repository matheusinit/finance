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
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      redirect_to '/'
    end
  end
end
