# デザインシステムのコンポーネント一覧用コントローラー。
# 開発環境でのみルートが定義されるため、本番では /design_system にアクセスできません。
class DesignSystemController < ApplicationController
  layout "design_system"
  def index
  end

  def alerts
  end

  def buttons
  end

  def cards
  end

  def form_fields
  end

  def typography
  end

  def tokens
  end
end
