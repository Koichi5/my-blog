class Like < ApplicationRecord
  belongs_to :post
  belongs_to :user, optional: true

  validates :post_id, uniqueness: { scope: :user_id }, if: -> { user_id.present? }
  validates :post_id, uniqueness: { scope: :guest_identifier }, if: -> { guest_identifier.present? }
end
