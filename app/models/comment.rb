class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user, optional: true

  validates :content, presence: true
  validates :guest_name, presence: true, if: -> { user_id.nil? }

  def author_name
    user&.name || guest_name || "ゲスト"
  end
end
