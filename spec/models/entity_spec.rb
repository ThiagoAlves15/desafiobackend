RSpec.describe Entity, type: :model do
  describe "associations" do
    it { is_expected.to belong_to :account }

    it { is_expected.to have_many :entities_users }

    it { is_expected.to have_many :users }
  end
end
