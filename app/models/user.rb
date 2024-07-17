require "bcrypt"

class User < ApplicationRecord
  include BCrypt

  attr_accessor :password

  has_one :accounts, dependent: :delete_all

  validates_presence_of :name, :email, :password
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :validate_password
  before_save :encrypt_password

  private

  def encrypt_password
    if password.present?
      cost = 12
      password_salt = BCrypt::Engine.generate_salt(cost)
      self.password_digest = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end

  def validate_password
    return if password.blank?

    unless password.length >= 10
      errors.add(:password, "must be at least 10 characters")
    end

    unless password.match?(/\A(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[.-^])/)
      errors.add(:password, "must contain at least one lowercase letter, one uppercase letter, one special character, and one number")
    end
  end
end
