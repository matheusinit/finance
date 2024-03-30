class UserController < ApplicationController
  def create
    logger.debug "name: #{params[:name]}"
    logger.debug "email: #{params[:email]}"
    logger.debug "password: #{params[:password]}"

    user = User.new
    user.id = SecureRandom.uuid
    user.name = params[:name]
    user.email = params[:email]
    user.password = params[:password]
    user.save
  end
end
