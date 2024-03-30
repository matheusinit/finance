class User < ApplicationRecord
  has_secure_password
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 10 },
            format: { with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[\W_])/,
               message: "must contain at least one lowercase letter, one uppercase letter, one special character, and one number" }
end
