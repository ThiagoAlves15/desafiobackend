RSpec.describe CreateAccount do
  describe "#call" do
    subject(:call) { described_class.call(payload) }

    context "when account is created" do
      before { allow(NotifyPartner).to receive(:new).and_return(notify_partner_double) }
      let(:notify_partner_double) { instance_double(NotifyPartner) }

      let(:from_partner) { false }
      let(:many_partners) { false }
      let(:payload) do
        {
          name: Faker::Company.name,
          from_partner: from_partner,
          many_partners: many_partners,
          users: [
            {
              first_name: Faker::Name.first_name,
              last_name: Faker::Name.last_name,
              email: Faker::Internet.email(domain: "example.com"),
              phone: "(11) 97111-0101",
            },
          ],
        }
      end
      let(:expected_result) { ApplicationService::Result.new(true, Account.last, nil) }

      it { is_expected.to eql(expected_result) }

      context "when account is not a partner" do
        it "notifies partner" do
          expect(notify_partner_double).to_not receive(:perform)

          call
        end
      end

      context "when account is partner" do
        let(:from_partner) { true }

        it "does not notify partners" do
          expect(notify_partner_double).to receive(:perform).once

          call
        end
      end

      context "when account is from many partners" do
        let(:from_partner) { true }
        let(:many_partners) { true }

        it "does not notify partners" do
          expect(notify_partner_double).to receive(:perform).twice

          call
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
              phone: "(11) 97111-0101",
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
