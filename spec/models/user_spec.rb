require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'is invalid without a name' do
      user = build(:user, name: nil)
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("can't be blank")
    end

    it 'is invalid with a name longer than 50 characters' do
      user = build(:user, name: 'a' * 51)
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("is too long (maximum is 50 characters)")
    end

    it 'is invalid without an email' do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'is invalid with a duplicate email' do
      create(:user, email: 'test@example.com')
      user = build(:user, email: 'test@example.com')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("has already been taken")
    end
  end

  describe 'associations' do
    it 'has many posts' do
      user = create(:user)
      post = create(:post, user: user)
      expect(user.posts).to include(post)
    end

    it 'has many comments' do
      user = create(:user)
      comment = create(:comment, :with_user, user: user)
      expect(user.comments).to include(comment)
    end

    it 'has many likes' do
      user = create(:user)
      like = create(:like, :with_user, user: user)
      expect(user.likes).to include(like)
    end

    it 'destroys associated posts when user is destroyed' do
      user = create(:user)
      expect { user.destroy }.to change { Post.count }.by(-1)
    end

    it 'destroys associated comments when user is destroyed' do
      user = create(:user)
      expect { user.destroy }.to change { Comment.count }.by(-1)
    end

    it 'destroys associated likes when user is destroyed' do
      user = create(:user)
      expect { user.destroy }.to change { Like.count }.by(-1)
    end
  end

  describe 'enum' do
    it 'has role enum' do
      user = create(:user, role: :general)
      expect(user.general?).to be true
      expect(user.admin?).to be false

      user = create(:user, :admin)
      expect(user.admin?).to be true
      expect(user.general?).to be false
    end
  end
end
