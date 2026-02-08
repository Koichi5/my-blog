class CommentsController < ApplicationController
  before_action :set_post
  before_action :set_comment, only: [ :destroy ]
  before_action :check_authorization, only: [ :destroy ]

  def create
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user if user_signed_in?

    if @comment.save
      redirect_to @post, notice: "コメントを投稿しました。"
    else
      flash[:alert] = "コメントの投稿に失敗しました: #{@comment.errors.full_messages.join(', ')}"
      redirect_to @post
    end
  end

  def destroy
    @comment.destroy
    redirect_to @post, notice: "コメントを削除しました。"
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  def check_authorization
    unless user_signed_in? && (current_user == @comment.user || current_user.admin?)
      redirect_to @post, alert: "このコメントを削除する権限がありません。"
    end
  end

  def comment_params
    params.require(:comment).permit(:content, :guest_name)
  end
end
