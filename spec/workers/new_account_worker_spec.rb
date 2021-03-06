require "./lib/workers/new_account_worker"

RSpec.describe Workers::NewAccountWorker do
  describe "#perform" do
    subject(:perform) { described_class.new.perform(sqs_msg, body) }

    before { allow(CreateAccount).to receive(:call) }

    let(:sqs_msg) do
      Aws::SQS::Client.new.send_message(
        queue_url: "https://eurozone.amazonaws.com/111111111111/new_account",
        message_body: body.to_s
      )
    end

    let(:body) do
      {
        account: {
          name: Faker::Superhero.name,
        },
        users: [
          {
            email: Faker::Internet.email,
            first_name: Faker::Name.first_name,
            last_name: Faker::Name.last_name,
            phone: Faker::PhoneNumber.cell_phone,
          },
        ],
      }
    end

    context "when payload is valid" do
      it "creates a new account" do
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
