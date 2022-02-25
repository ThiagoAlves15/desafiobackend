module Workers
  class NewAccountWorker
    include Shoryuken::Worker

    class CreateAccountFailed < StandardError; end

    shoryuken_options queue: "new_account", auto_delete: true, body_parser: :json

    def perform(sqs_msg, body)
      begin
        CreateAccount.call(account_params(body))
      rescue StandardError
        Rails.logger.error("Could not create account")

        raise Workers::NewAccountWorker::CreateAccountFailed
      end
    end

    private

    def account_params(body)
      if body["account"].present?
        {
          name: body["account"]["name"],
          from_partner: body["account"]["from_partner"],
          many_partners: body["account"]["many_partners"],
          users: users_params(body["users"]),
        }
      elsif body[:account].present?
        {
          name: body[:account][:name],
          from_partner: body[:account][:from_partner],
          many_partners: body[:account][:many_partners],
          users: users_params(body[:users]),
        }
      else
        raise Workers::NewAccountWorker::CreateAccountFailed
      end
    end

    def users_params(users)
      users.map do |user|
        {
          first_name: user["first_name"],
          last_name: user["last_name"],
          email: user["email"],
          phone: user["phone"].to_s.gsub(/\D/, ""),
        }
      end
    end
  end
end
