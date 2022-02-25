class CreateAccount < ApplicationService
  def initialize(payload)
    @payload = payload
    @errors = []
  end

  def call
    if account_valid?
      account = Account.new(account_params)

      if account.save && User.insert_all(users_params)
        notify_partner if @payload[:from_partner] == true

        Result.new(true, account)
      else
        @errors << account.errors.full_messages

        Result.new(false, nil, @errors.join(","))
      end
    else
      @errors << "Account is not valid"

      Result.new(false, nil, @errors.join(","))
    end
  end

  private

  def account_valid?
    @payload.present?
  end

  def account_params
    {
      name: @payload[:name],
      active: from_fintera?,
    }
  end

  def from_fintera?
    return false unless @payload[:name].include? "Fintera"

    @payload[:users].each do |user|
      return true if user[:email].include? "fintera.com.br"
    end

    false
  end

  def users_params
    @payload[:users].map do |user|
      {
        first_name: user[:first_name],
        last_name: user[:last_name],
        email: user[:email],
        phone: user[:phone].to_s.gsub(/\D/, ""),
        created_at: Time.zone.now,
        updated_at: Time.zone.now,
      }
    end
  end

  def notify_partner
    NotifyPartner.new.perform
    NotifyPartner.new("another").perform if @payload[:many_partners] == true
  end
end
