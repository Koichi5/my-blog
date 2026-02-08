#  # FactoryBotなし（毎回書く必要がある）
#  comment = Comment.create(
#    post: Post.create(user: User.create(...)),
#    content: "テストコメント",
#    guest_name: "ゲスト"
#  )

#  # FactoryBotあり（シンプル）
#  comment = create(:comment, :as_guest)

FactoryBot.define do
  factory :comment do
    association :post
    content { Faker::Lorem.paragraph(sentence_count: 3) }

    trait :with_user do
      association :user
      guest_name { nil }
    end

    trait :as_guest do
      user { nil }
      guest_name { Faker::Name.name }
    end
  end
end
