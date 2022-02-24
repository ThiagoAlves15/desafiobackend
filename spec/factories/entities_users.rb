FactoryBot.define do
  factory :entities_user do
    association :entity
    association :user
  end
end
