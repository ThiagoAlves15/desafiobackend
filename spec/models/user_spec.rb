RSpec.describe User do
  describe "associations" do
    it { is_expected.to have_many :entities_users }

    it { is_expected.to have_many :entities }
  end
end
