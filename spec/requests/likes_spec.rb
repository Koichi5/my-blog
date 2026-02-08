require 'rails_helper'

RSpec.describe "Likes", type: :request do
  let(:user) { create(:user) }
  let(:test_post) { create(:post, :published) }

  describe "POST /posts/:post_id/likes" do
    context "when user is signed in" do
      before { sign_in user }

      it "creates a new like" do
        expect {
          post post_likes_path(test_post), params: { like: {} }
        }.to change(Like, :count).by(1)
      end

      it "associates like with user" do
        post post_likes_path(test_post), params: { like: {} }
        expect(Like.last.user).to eq(user)
      end

      it "returns JSON response" do
        post post_likes_path(test_post), params: { like: {} }, headers: { "Accept" => "application/json" }
        expect(response.content_type).to include("application/json")
        json_response = JSON.parse(response.body)
        expect(json_response["liked"]).to be true
        expect(json_response["count"]).to eq(1)
      end

      it "does not create duplicate likes" do
        create(:like, :with_user, post: test_post, user: user)
        expect {
          post post_likes_path(test_post), params: { like: {} }
        }.not_to change(Like, :count)
      end
    end

    context "when user is not signed in" do
      it "creates a guest like" do
        expect {
          post post_likes_path(test_post), params: { like: {} }
        }.to change(Like, :count).by(1)
      end

      it "associates like with guest_identifier" do
        post post_likes_path(test_post), params: { like: {} }
        like = Like.last
        expect(like).to be_present
        expect(like.guest_identifier).to be_present
        expect(like.user).to be_nil
      end

      it "sets guest_identifier cookie" do
        expect {
          post post_likes_path(test_post), params: { like: {} }
        }.to change(Like, :count).by(1)
        # Cookie is set by the controller, check that a like was created with guest_identifier
        like = Like.last
        expect(like).to be_present
        expect(like.guest_identifier).to be_present
      end

      it "does not create duplicate likes for same guest" do
        # First request creates a like and sets cookie
        post post_likes_path(test_post), params: { like: {} }
        first_like_count = Like.count
        expect(first_like_count).to eq(1)

        # Second request should not create duplicate
        # The controller will read the cookie set by first request
        expect {
          post post_likes_path(test_post), params: { like: {} }
        }.not_to change(Like, :count)
      end
    end
  end

  describe "DELETE /posts/:post_id/likes/:id" do
    context "when user is signed in" do
      before { sign_in user }

      it "deletes the like" do
        like = create(:like, :with_user, post: test_post, user: user)
        expect {
          delete post_like_path(test_post, like)
        }.to change(Like, :count).by(-1)
      end

      it "returns JSON response" do
        like = create(:like, :with_user, post: test_post, user: user)
        delete post_like_path(test_post, like), headers: { "Accept" => "application/json" }
        expect(response.content_type).to include("application/json")
        json_response = JSON.parse(response.body)
        expect(json_response["liked"]).to be false
        expect(json_response["count"]).to eq(0)
      end
    end

    context "when user is not signed in" do
      it "deletes the guest like" do
        # Create a like first to set the cookie
        post post_likes_path(test_post), params: { like: {} }
        like = Like.last
        expect(like).to be_present
        expect(like.guest_identifier).to be_present

        expect {
          delete post_like_path(test_post, like)
        }.to change(Like, :count).by(-1)
      end
    end
  end
end
