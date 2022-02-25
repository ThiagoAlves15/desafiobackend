require "./lib/workers/new_account_worker"

RSpec.describe Workers::NewAccountWorker do
  describe "#perform" do
    subject(:perform) { described_class.new.perform(sqs_msg, body) }

    before { allow(CreateAccount).to receive(:call) }
    before { allow(Shoryuken).to receive(:launcher_executor) }

    let(:sqs_msg) {
      Aws::SQS::Client.new(stub_responses: true).send_message(
        queue_url: "https://sqs.sa-east-1.amazonaws.com/111111111111/new_account",
        message_body: "#{body}",
      )
    }

    let(:body) do
      {
        "account": {
          "name": Faker::Superhero.name
        },
        "users": [
          {
            "email": Faker::Internet.email,
            "first_name": Faker::Name.first_name,
            "last_name": Faker::Name.last_name,
            "phone": Faker::PhoneNumber.cell_phone
          }
        ]
      }
    end

    # {
    #   "account": {
    #     "name": "Faker::Superhero.name"
    #   },
    #   "users": [
    #     {
    #       "email": "Faker::Internet.email",
    #       "first_name": "Faker::Name.first_name",
    #       "last_name": "Faker::Name.last_name",
    #       "phone": "Faker::PhoneNumber.cell_phone"
    #     }
    #   ]
    # }

    context "when payload is valid" do
      it "creates a new account" do
        # rspec spec/workers/new_account_worker_spec.rb
        expect { perform }.not_to raise_error

        expect(CreateAccount).to have_received(:call)
      end
    end

    context "when payload is invalid" do
      let(:body) { {} }

      it "raises an error" do
        expect { perform }.to raise_error(Workers::NewAccountWorker::CreateAccountFailed)
      end
    end
  end
end
