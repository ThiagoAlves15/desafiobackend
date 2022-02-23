class Entity < ApplicationRecord
  belongs_to :account
  has_many :entities_users
  has_many :users, through: :entities_users
end
