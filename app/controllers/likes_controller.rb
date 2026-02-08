class LikesController < ApplicationController
  before_action :set_post
  before_action :set_like, only: [ :destroy ]

  def create
    @like = @post.likes.build(like_params)
    @like.user = current_user if user_signed_in?
    @like.guest_identifier = get_or_create_guest_identifier unless user_signed_in?

    respond_to do |format|
      if @like.save
        format.html { redirect_to @post, notice: "いいねしました。" }
        format.json { render json: { liked: true, count: @post.likes.count, like_id: @like.id } }
      else
        format.html { redirect_to @post, alert: "いいねに失敗しました。" }
        format.json { render json: { error: @like.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @like.destroy
        format.html { redirect_to @post, notice: "いいねを取り消しました。" }
        format.json { render json: { liked: false, count: @post.likes.count } }
      else
        format.html { redirect_to @post, alert: "いいねの取り消しに失敗しました。" }
        format.json { render json: { error: "削除に失敗しました" }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_like
    if user_signed_in?
      @like = @post.likes.find_by(user_id: current_user.id)
    else
      guest_id = get_or_create_guest_identifier
      @like = @post.likes.find_by(guest_identifier: guest_id)
    end
  end

  def like_params
    params.require(:like).permit(:guest_identifier)
  end

  def get_or_create_guest_identifier
    guest_id = cookies.signed[:guest_identifier]
    unless guest_id
      guest_id = SecureRandom.hex(32)
      cookies.signed[:guest_identifier] = { value: guest_id, expires: 1.year.from_now }
    end
    guest_id
  end
end
