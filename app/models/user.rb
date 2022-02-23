class User < ApplicationRecord
  has_many :entities_users
  has_many :entities, through: :entities_users

  after_create :send_welcome_email

  def send_welcome_email
    call_to_action = { label: "Acesse agora", url: "https://fintera.com.br" }
    UserMailer.welcome_email(self, call_to_action).deliver_now
  end
end
