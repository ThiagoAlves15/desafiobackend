RSpec.describe "Api::V1::AccountsController", type: :request do
  describe "POST #create" do
    before { post api_v1_accounts_path(params: params) }

    context "when valid params" do
      let(:params) do
        {
          account: {
            name: Faker::Superhero.name, from_partner: true,
            users: [{
              email: Faker::Internet.email,
              first_name: Faker::Name.female_first_name,
              last_name: Faker::Name.last_name,
              phone: Faker::PhoneNumber.cell_phone,
            }],
          },
        }
      end

      it "renders 200 success" do
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to include({ "id" => Account.last.id })
      end
    end

    context "when invalid params" do
      let(:params) do
        {
          account: {
            name: nil, from_partner: true,
            users: [{
              email: Faker::Internet.email,
              first_name: Faker::Name.female_first_name,
              last_name: Faker::Name.last_name,
              phone: Faker::PhoneNumber.cell_phone,
            }],
          },
        }
      end

      it "renders 402 unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include({"error" => "Name can't be blank"})
      end
    end

    context "when missing params" do
      let(:params) do
        {
          account: {
            users: [{
              email: Faker::Internet.email,
              first_name: Faker::Name.female_first_name,
              last_name: Faker::Name.last_name,
              phone: Faker::PhoneNumber.cell_phone,
            }],
          },
        }
      end

      xit "renders 402 unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include({"error" => "Name can't be blank"})
      end
    end
  end
end
