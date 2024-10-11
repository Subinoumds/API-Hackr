class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  ROLES = %w[admin user].freeze

  validates :role, inclusion: { in: ROLES }
end