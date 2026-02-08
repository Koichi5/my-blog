require 'rails_helper'

RSpec.describe "Comments", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:admin_user) { create(:user, :admin) }
  let(:test_post) { create(:post, :published) }
  let(:comment) { create(:comment, :with_user, post: test_post, user: user) }
  let(:guest_comment) { create(:comment, :as_guest, post: test_post) }

  describe "POST /posts/:post_id/comments" do
    context "when user is signed in" do
      before { sign_in user }

      it "creates a new comment" do
        expect {
          post post_comments_path(test_post), params: { comment: { content: "Test comment" } }
        }.to change(Comment, :count).by(1)
      end

      it "associates comment with user" do
        post post_comments_path(test_post), params: { comment: { content: "Test comment" } }
        expect(Comment.last.user).to eq(user)
      end

      it "redirects to the post page" do
        post post_comments_path(test_post), params: { comment: { content: "Test comment" } }
        expect(response).to redirect_to(test_post)
      end
    end

    context "when user is not signed in" do
      it "creates a guest comment" do
        expect {
          post post_comments_path(test_post), params: { comment: { content: "Test comment", guest_name: "Guest User" } }
        }.to change(Comment, :count).by(1)
      end

      it "associates comment with guest_name" do
        post post_comments_path(test_post), params: { comment: { content: "Test comment", guest_name: "Guest User" } }
        expect(Comment.last.guest_name).to eq("Guest User")
        expect(Comment.last.user).to be_nil
      end

      it "is invalid without guest_name" do
        expect {
          post post_comments_path(test_post), params: { comment: { content: "Test comment" } }
        }.not_to change(Comment, :count)
      end
    end
  end

  describe "DELETE /posts/:post_id/comments/:id" do
    context "when user is the owner" do
      before { sign_in user }

      it "deletes the comment" do
        comment_to_delete = create(:comment, :with_user, post: test_post, user: user)
        expect {
          delete post_comment_path(test_post, comment_to_delete)
        }.to change(Comment, :count).by(-1)
      end

      it "redirects to the post page" do
        delete post_comment_path(test_post, comment)
        expect(response).to redirect_to(test_post)
      end
    end

    context "when user is admin" do
      before { sign_in admin_user }

      it "deletes the comment" do
        comment_to_delete = create(:comment, :with_user, post: test_post, user: user)
        expect {
          delete post_comment_path(test_post, comment_to_delete)
        }.to change(Comment, :count).by(-1)
      end
    end

    context "when user is not the owner" do
      before { sign_in other_user }

      it "does not delete the comment" do
        expect {
          delete post_comment_path(test_post, comment)
        }.not_to change(Comment, :count)
      end

      it "redirects to the post page" do
        delete post_comment_path(test_post, comment)
        expect(response).to redirect_to(test_post)
      end
    end

    context "when user is not signed in" do
      it "does not delete the comment" do
        comment_to_delete = create(:comment, :as_guest, post: test_post)
        expect {
          delete post_comment_path(test_post, comment_to_delete)
        }.not_to change(Comment, :count)
      end

      it "redirects to the post page" do
        comment_to_delete = create(:comment, :as_guest, post: test_post)
        delete post_comment_path(test_post, comment_to_delete)
        expect(response).to redirect_to(test_post)
      end
    end
  end
end
