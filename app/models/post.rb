class Post < ApplicationRecord
  belongs_to :user

  enum status: { draft: 0, published: 1 }

  validates :title, presence: true, length: { maximum: 150 }
  validates :body, presence: true

  # 公開された記事のみ絞り込み
  scope :published, -> { where(status: :published) }
  # 公開日時で降順に並び替え
  # Post.published.recentで公開された投稿のみを公開日時の新しい順で取得
  scope :recent, -> { order(published_at: :desc) }

  # `status`が変更された場合に`published_at`を更新
  before_save :set_published_at, if: :will_save_change_to_status?

  # dependent: :destroy は親が削除されると、子も削除される（コールバック実行）
  # その他のdependent
  # :delete_all	親が削除されると、子も削除される（コールバックなし、高速）
  # :nullify	親が削除されると、子の外部キーを NULL に設定
  # :restrict_with_error	子が存在する場合、親の削除をエラーで阻止
  # :restrict_with_exception	子が存在する場合、親の削除を例外で阻止
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  # has_many_attached: ファイル添付（Active Storage）。画像や動画などのファイルを扱う。
  has_many_attached :images
  has_many_attached :videos

  private

  def set_published_at
    self.published_at = Time.current if published? && published_at.nil?
  end
end
