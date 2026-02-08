require 'rails_helper'

RSpec.describe "Posts", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:admin_user) { create(:user, :admin) }
  let(:test_post) { create(:post, :published, user: user) }
  let(:draft_post) { create(:post, :draft, user: user) }

  describe "GET /posts" do
    it "returns http success" do
      get posts_path
      expect(response).to have_http_status(:success)
    end

    it "displays only published posts" do
      published_post = create(:post, :published)
      draft_post = create(:post, :draft)

      get posts_path
      expect(response.body).to include(published_post.title)
      expect(response.body).not_to include(draft_post.title)
    end
  end

  describe "GET /posts/:id" do
    it "returns http success" do
      get post_path(test_post)
      expect(response).to have_http_status(:success)
    end

    it "displays the post content" do
      get post_path(test_post)
      expect(response.body).to include(test_post.title)
      expect(response.body).to include(test_post.body)
    end
  end

  describe "GET /posts/new" do
    context "when user is signed in" do
      before { sign_in user }

      it "returns http success" do
        get new_post_path
        expect(response).to have_http_status(:success)
      end
    end

    context "when user is not signed in" do
      it "redirects to login page" do
        get new_post_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST /posts" do
    context "when user is signed in" do
      before { sign_in user }

      it "creates a new post" do
        expect {
          post posts_path, params: { post: { title: "New Post", body: "Post body", status: :draft } }
        }.to change(Post, :count).by(1)
      end

      it "redirects to the post page" do
        post posts_path, params: { post: { title: "New Post", body: "Post body", status: :published } }
        expect(response).to redirect_to(Post.last)
      end

      it "sets published_at when status is published" do
        post posts_path, params: { post: { title: "New Post", body: "Post body", status: :published } }
        expect(Post.last.published_at).not_to be_nil
      end
    end

    context "when user is not signed in" do
      it "redirects to login page" do
        post posts_path, params: { post: { title: "New Post", body: "Post body" } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /posts/:id/edit" do
    context "when user is the owner" do
      before { sign_in user }

      it "returns http success" do
        get edit_post_path(test_post)
        expect(response).to have_http_status(:success)
      end
    end

    context "when user is admin" do
      before { sign_in admin_user }

      it "returns http success" do
        get edit_post_path(test_post)
        expect(response).to have_http_status(:success)
      end
    end

    context "when user is not the owner" do
      before { sign_in other_user }

      it "redirects to posts index" do
        get edit_post_path(test_post)
        expect(response).to redirect_to(posts_path)
      end
    end

    context "when user is not signed in" do
      it "redirects to login page" do
        get edit_post_path(test_post)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "PATCH /posts/:id" do
    context "when user is the owner" do
      before { sign_in user }

      it "updates the post" do
        patch post_path(test_post), params: { post: { title: "Updated Title" } }
        test_post.reload
        expect(test_post.title).to eq("Updated Title")
      end

      it "redirects to the post page" do
        patch post_path(test_post), params: { post: { title: "Updated Title" } }
        expect(response).to redirect_to(test_post)
      end
    end

    context "when user is not the owner" do
      before { sign_in other_user }

      it "does not update the post" do
        original_title = test_post.title
        patch post_path(test_post), params: { post: { title: "Updated Title" } }
        test_post.reload
        expect(test_post.title).to eq(original_title)
      end

      it "redirects to posts index" do
        patch post_path(test_post), params: { post: { title: "Updated Title" } }
        expect(response).to redirect_to(posts_path)
      end
    end
  end

  describe "DELETE /posts/:id" do
    context "when user is the owner" do
      before { sign_in user }

      it "deletes the post" do
        post_to_delete = create(:post, user: user)
        expect {
          delete post_path(post_to_delete)
        }.to change(Post, :count).by(-1)
      end

      it "redirects to posts index" do
        delete post_path(test_post)
        expect(response).to redirect_to(posts_path)
      end
    end

    context "when user is admin" do
      before { sign_in admin_user }

      it "deletes the post" do
        post_to_delete = create(:post, user: user)
        expect {
          delete post_path(post_to_delete)
        }.to change(Post, :count).by(-1)
      end
    end

    context "when user is not the owner" do
      before { sign_in other_user }

      it "does not delete the post" do
        post_to_delete = create(:post, user: user)
        expect {
          delete post_path(post_to_delete)
        }.not_to change(Post, :count)
      end

      it "redirects to posts index" do
        delete post_path(test_post)
        expect(response).to redirect_to(posts_path)
      end
    end
  end
end
