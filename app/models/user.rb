class User < ApplicationRecord
  has_secure_password
  validates_presence_of :name, :email
  # validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  # validate :validate_password

  # private
  #
  # def validate_password
  #   return if password.blank?
  #
  #   unless password.length >= 10
  #     errors.add(:password, "must be at least 10 characters")
  #   end
  #
  #   unless password.match?(/\A(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[.-^])/)
  #     errors.add(:password, "must contain at least one lowercase letter, one uppercase letter, one special character, and one number")
  #   end
  # end
end
