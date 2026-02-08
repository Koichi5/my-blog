require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      comment = build(:comment, :as_guest)
      expect(comment).to be_valid
    end

    it 'is invalid without content' do
      comment = build(:comment, content: nil)
      expect(comment).not_to be_valid
      expect(comment.errors[:content]).to include("can't be blank")
    end

    it 'is invalid without guest_name when user is nil' do
      comment = build(:comment, user: nil, guest_name: nil)
      expect(comment).not_to be_valid
      expect(comment.errors[:guest_name]).to include("can't be blank")
    end

    it 'is valid without guest_name when user is present' do
      user = create(:user)
      comment = build(:comment, :with_user, user: user, guest_name: nil)
      expect(comment).to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to a post' do
      post = create(:post)
      comment = create(:comment, :as_guest, post: post)
      expect(comment.post).to eq(post)
    end

    it 'belongs to a user optionally' do
      user = create(:user)
      comment = create(:comment, :with_user, user: user)
      expect(comment.user).to eq(user)
    end

    it 'can exist without a user' do
      comment = create(:comment, :as_guest)
      expect(comment.user).to be_nil
      expect(comment.guest_name).to be_present
    end
  end

  describe '#author_name' do
    it 'returns user name when user is present' do
      user = create(:user, name: 'John Doe')
      comment = create(:comment, :with_user, user: user)
      expect(comment.author_name).to eq('John Doe')
    end

    it 'returns guest_name when user is nil' do
      comment = create(:comment, :as_guest, guest_name: 'Guest User')
      expect(comment.author_name).to eq('Guest User')
    end

    it 'returns "ゲスト" when both user and guest_name are nil' do
      comment = build(:comment, user: nil, guest_name: nil)
      expect(comment.author_name).to eq('ゲスト')
    end
  end
end
