FactoryBot.define do
  factory :entity do
    name { Faker::Company.bs }
    association :account
  end
end
