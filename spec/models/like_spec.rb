require 'rails_helper'

RSpec.describe Like, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      like = build(:like, :as_guest)
      expect(like).to be_valid
    end

    it 'is invalid when user likes the same post twice' do
      user = create(:user)
      post = create(:post)
      create(:like, :with_user, user: user, post: post)

      duplicate_like = build(:like, :with_user, user: user, post: post)
      expect(duplicate_like).not_to be_valid
      expect(duplicate_like.errors[:post_id]).to be_present
    end

    it 'is invalid when guest likes the same post twice with same identifier' do
      post = create(:post)
      guest_identifier = SecureRandom.uuid
      create(:like, :as_guest, post: post, guest_identifier: guest_identifier)

      duplicate_like = build(:like, :as_guest, post: post, guest_identifier: guest_identifier)
      expect(duplicate_like).not_to be_valid
      expect(duplicate_like.errors[:post_id]).to be_present
    end

    it 'is valid when different users like the same post' do
      post = create(:post)
      user1 = create(:user)
      user2 = create(:user)

      like1 = create(:like, :with_user, user: user1, post: post)
      like2 = build(:like, :with_user, user: user2, post: post)

      expect(like1).to be_valid
      expect(like2).to be_valid
    end

    it 'is valid when different guests like the same post' do
      post = create(:post)
      like1 = create(:like, :as_guest, post: post)
      like2 = build(:like, :as_guest, post: post)

      expect(like1).to be_valid
      expect(like2).to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to a post' do
      post = create(:post)
      like = create(:like, post: post)
      expect(like.post).to eq(post)
    end

    it 'belongs to a user optionally' do
      user = create(:user)
      like = create(:like, :with_user, user: user)
      expect(like.user).to eq(user)
    end

    it 'can exist without a user' do
      like = create(:like, :as_guest)
      expect(like.user).to be_nil
      expect(like.guest_identifier).to be_present
    end
  end
end
