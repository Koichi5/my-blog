class PostsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_post, only: [ :show, :edit, :update, :destroy ]
  before_action :check_authorization, only: [ :edit, :update, :destroy ]

  def index
    @posts = Post.published.recent
  end

  def show
    @liked = if user_signed_in?
               @post.likes.exists?(user_id: current_user.id)
    else
               guest_id = cookies.signed[:guest_identifier]
               guest_id.present? && @post.likes.exists?(guest_identifier: guest_id)
    end
    @current_like = if user_signed_in?
                      @post.likes.find_by(user_id: current_user.id)
    else
                      guest_id = cookies.signed[:guest_identifier]
                      guest_id.present? ? @post.likes.find_by(guest_identifier: guest_id) : nil
    end
    @likes_count = @post.likes.count
  end

  def new
    @post = current_user.posts.build
  end

  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      redirect_to @post, notice: "記事を作成しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      redirect_to @post, notice: "記事を更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_path, notice: "記事を削除しました。"
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def check_authorization
    unless current_user == @post.user || current_user&.admin?
      redirect_to posts_path, alert: "この記事を編集・削除する権限がありません。"
    end
  end

  def post_params
    params.require(:post).permit(:title, :body, :status, images: [], videos: [])
  end
end
