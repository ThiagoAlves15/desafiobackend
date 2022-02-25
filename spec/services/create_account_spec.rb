RSpec.describe CreateAccount do
  describe "#call" do
    subject(:create_account) { described_class.call(payload) }

    let(:from_partner) { false }
    let(:many_partners) { false }
    let(:account_name) { Faker::Company.name }
    let(:user_email) { Faker::Internet.email(domain: "example.com") }
    let(:payload) do
      {
        name: account_name,
        from_partner: from_partner,
        many_partners: many_partners,
        users: [
          {
            first_name: Faker::Name.first_name,
            last_name: Faker::Name.last_name,
            email: user_email,
            phone: Faker::PhoneNumber.cell_phone,
          },
        ],
      }
    end

    context "when account is created" do
      let(:expected_result) { ApplicationService::Result.new(true, Account.last, nil) }

      it { is_expected.to eql(expected_result) }
    end

    describe "#notify_partners" do
      before { allow(NotifyPartner).to receive(:new).and_return(notify_partner_double) }

      let(:notify_partner_double) { instance_double(NotifyPartner) }

      context "when account is not a partner" do
        it "notifies partner" do
          expect(notify_partner_double).not_to receive(:perform)

          create_account
        end
      end

      context "when account is partner" do
        let(:from_partner) { true }

        it "does not notify partners" do
          expect(notify_partner_double).to receive(:perform).once

          create_account
        end
      end

      context "when account is from many partners" do
        let(:from_partner) { true }
        let(:many_partners) { true }

        it "does not notify partners" do
          expect(notify_partner_double).to receive(:perform).twice

          create_account
        end
      end
    end

    describe "#from_fintera?" do
      context "when account not from fintera" do
        it "is not active" do
          expect(create_account.data.active).to be false
        end
      end

      context "when account from fintera but no user email from fintera" do
        let(:account_name) { "Fintera #{Faker::Company.name}" }

        it "is not active" do
          expect(create_account.data.active).to be false
        end
      end

      context "when account not from fintera but user email from fintera" do
        let(:user_email) { Faker::Internet.email(domain: "fintera.com.br") }

        it "is not active" do
          expect(create_account.data.active).to be false
        end
      end

      context "when account from fintera and user email from fintera" do
        let(:account_name) { "Fintera #{Faker::Company.name}" }
        let(:user_email) { Faker::Internet.email(domain: "fintera.com.br") }

        it "is active" do
          expect(create_account.data.active).to be true
        end
      end
    end

    context "when account is not created" do
      let(:payload) do
        {
          name: "",
          users: [
            {
              first_name: Faker::Name.first_name,
              last_name: Faker::Name.last_name,
              email: Faker::Internet.email,
              phone: Faker::PhoneNumber.cell_phone,
            },
          ],
        }
      end
      let(:expected_result) { ApplicationService::Result.new(false, nil, "Name can't be blank") }

      it { is_expected.to eql(expected_result) }
    end

    context "when payload is invalid" do
      let(:payload) { {} }
      let(:expected_result) { ApplicationService::Result.new(false, nil, "Account is not valid") }

      it { is_expected.to eql(expected_result) }
    end
  end
end
