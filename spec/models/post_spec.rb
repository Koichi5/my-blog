require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      post = build(:post)
      expect(post).to be_valid
    end

    it 'is invalid without a title' do
      post = build(:post, title: nil)
      expect(post).not_to be_valid
      expect(post.errors[:title]).to include("can't be blank")
    end

    it 'is invalid with a title longer than 150 characters' do
      post = build(:post, title: 'a' * 151)
      expect(post).not_to be_valid
      expect(post.errors[:title]).to include("is too long (maximum is 150 characters)")
    end

    it 'is invalid without a body' do
      post = build(:post, body: nil)
      expect(post).not_to be_valid
      expect(post.errors[:body]).to include("can't be blank")
    end

    it 'is invalid without a user' do
      post = build(:post, user: nil)
      expect(post).not_to be_valid
      expect(post.errors[:user]).to include("must exist")
    end
  end

  describe 'associations' do
    it 'belongs to a user' do
      user = create(:user)
      post = create(:post, user: user)
      expect(post.user).to eq(user)
    end

    it 'has many comments' do
      post = create(:post)
      comment = create(:comment, :as_guest, post: post)
      expect(post.comments).to include(comment)
    end

    it 'has many likes' do
      post = create(:post)
      like = create(:like, :as_guest, post: post)
      expect(post.likes).to include(like)
    end

    it 'destroys associated comments when post is destroyed' do
      post = create(:post)
      expect { post.destroy }.to change { Comment.count }.by(-1)
    end

    it 'destroys associated likes when post is destroyed' do
      post = create(:post)
      expect { post.destroy }.to change { Like.count }.by(-1)
    end
  end

  describe 'enum' do
    it 'has status enum' do
      post = create(:post, status: :draft)
      expect(post.draft?).to be true
      expect(post.published?).to be false

      post = create(:post, :published)
      expect(post.published?).to be true
      expect(post.draft?).to be false
    end
  end

  describe 'scopes' do
    it 'returns only published posts' do
      published_post = create(:post, :published)
      draft_post = create(:post, :draft)

      expect(Post.published).to include(published_post)
      expect(Post.published).not_to include(draft_post)
    end

    it 'returns posts ordered by published_at desc' do
      post1 = create(:post, :published, published_at: 2.days.ago)
      post2 = create(:post, :published, published_at: 1.day.ago)
      post3 = create(:post, :published, published_at: 3.days.ago)

      expect(Post.recent.to_a).to eq([ post2, post1, post3 ])
    end
  end

  describe 'callbacks' do
    it 'sets published_at when status changes to published' do
      post = create(:post, :draft)
      expect(post.published_at).to be_nil

      post.update(status: :published)
      expect(post.published_at).not_to be_nil
      expect(post.published_at).to be_within(1.second).of(Time.current)
    end

    it 'does not update published_at if already set' do
      published_at = 1.day.ago
      post = create(:post, :published, published_at: published_at)

      post.update(title: 'New Title')
      expect(post.published_at).to be_within(1.second).of(published_at)
    end
  end
end
