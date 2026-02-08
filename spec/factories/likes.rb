FactoryBot.define do
  factory :like do
    association :post

    trait :with_user do
      association :user
      guest_identifier { nil }
    end

    trait :as_guest do
      user { nil }
      guest_identifier { SecureRandom.uuid }
    end
  end
end
