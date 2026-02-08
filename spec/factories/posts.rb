FactoryBot.define do
  factory :post do
    association :user
    title { Faker::Lorem.sentence(word_count: 5) }
    body { Faker::Lorem.paragraph(sentence_count: 10) }
    status { :draft }

    trait :published do
      status { :published }
      published_at { Time.current }
    end

    trait :draft do
      status { :draft }
      published_at { nil }
    end
  end
end
