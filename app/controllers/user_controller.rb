class UserController < ApplicationController
  def create
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
