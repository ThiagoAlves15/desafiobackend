class CreateAccount < ApplicationService
  def initialize(payload)
    @payload = payload
    @errors = []
  end

  def call
    if !is_account_valid?
      @errors << "Account is not valid"

      Result.new(false, nil, @errors.join(","))
    else
      account = Account.new(account_params)

      if account.save && User.insert_all(users_params(account))
        notify_partner if @payload[:from_partner] == true

        Result.new(true, account)
      else
        @errors << account.errors.full_messages

        Result.new(false, nil, @errors.join(","))
      end
    end
  end

  private

  def is_account_valid?
    @payload.present?
  end

  def account_params
    {
      name: @payload[:name],
      active: is_from_fintera?,
    }
  end

  def is_from_fintera?
    return false unless @payload[:name].include? "Fintera"

    @payload[:users].each do |user|
      return true if user[:email].include? "fintera.com.br"
    end

    false
  end

  def users_params(account)
    # breaks when no users in payload, guard this
    @payload[:users].map do |user|
      {
        first_name: user[:first_name],
        last_name: user[:last_name],
        email: user[:email],
        phone: user[:phone].to_s.gsub(/\D/, ""),
        account_id: account.id,
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
