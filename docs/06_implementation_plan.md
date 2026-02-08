# 🚀 実装計画書

## 📋 概要

本ドキュメントは、MyBlogApp の実装を段階的に進めるための詳細な計画書です。
各フェーズで実装する機能、使用する技術、実装手順を明確に定義します。

---

## 🎯 実装フェーズ概要

| フェーズ    | 名称               | 主な実装内容                             | 想定期間 |
| ----------- | ------------------ | ---------------------------------------- | -------- |
| **Phase 0** | 環境構築・基盤準備 | Gem 追加、DB 設計、基本設定              | 1-2 日   |
| **Phase 1** | 認証機能           | Devise 導入、ユーザー管理                | 2-3 日   |
| **Phase 2** | 記事機能（CRUD）   | 記事投稿・編集・削除・一覧表示           | 3-4 日   |
| **Phase 3** | Markdown 対応      | Markdown レンダリング、プレビュー        | 1-2 日   |
| **Phase 4** | 画像・動画添付     | ActiveStorage 導入、ファイルアップロード | 2-3 日   |
| **Phase 5** | コメント機能       | コメント投稿・削除、ゲスト対応           | 2-3 日   |
| **Phase 6** | いいね機能         | いいね機能、ゲスト対応、Ajax             | 2-3 日   |
| **Phase 7** | UI/UX 改善         | デザイン調整、レスポンシブ対応           | 2-3 日   |
| **Phase 8** | テスト・品質保証   | RSpec 導入、テスト作成                   | 3-4 日   |
| **Phase 9** | デプロイ準備       | 本番環境設定、セキュリティ対策           | 2-3 日   |

**合計想定期間：約 3-4 週間（個人開発ペース想定）**

---

## 📦 Phase 0: 環境構築・基盤準備

### 実装タスク

1. **必要な Gem の追加**

   ```ruby
   # Gemfileに追加
   gem 'devise'                    # 認証機能
   gem 'redcarpet'                 # Markdownパーサー（またはkramdown）
   gem 'image_processing', '~> 1.2' # ActiveStorage画像処理
   gem 'rspec-rails'               # テストフレームワーク
   gem 'factory_bot_rails'         # テストデータ生成
   gem 'faker'                     # ダミーデータ生成
   ```

2. **データベース設計の実装**

   - `users`テーブル（Devise で自動生成されるが、role カラム追加）
   - `posts`テーブル
   - `comments`テーブル
   - `likes`テーブル
   - 外部キー制約の設定
   - インデックスの設定

3. **初期設定**
   - Devise の初期化
   - ActiveStorage の設定
   - ルーティングの基本設計

### 実装手順

```bash
# 1. Gem追加
bundle add devise
bundle add redcarpet
bundle add image_processing
bundle add rspec-rails --group development,test
bundle add factory_bot_rails --group development,test
bundle add faker --group development,test

# 2. Devise初期化
rails generate devise:install
rails generate devise User

# 3. マイグレーションファイル作成
rails generate migration AddRoleToUsers role:integer
rails generate model Post user:references title:string body:text status:integer published_at:datetime
rails generate model Comment post:references user:references content:text
rails generate model Like post:references user:references guest_identifier:string

# 4. マイグレーション実行
rails db:migrate

# 5. RSpec初期化
rails generate rspec:install
```

### チェックリスト

- [ ] 必要な Gem がインストール済み
- [ ] データベースマイグレーションが正常に実行できる
- [ ] モデルファイルが作成されている
- [ ] アソシエーションの基本構造が定義されている

---

## 🔐 Phase 1: 認証機能

### 実装タスク

1. **Devise 設定**

   - ユーザー登録・ログイン・ログアウト機能
   - パスワードリセット機能（オプション）
   - role カラムの enum 定義（general: 0, admin: 1）

2. **ユーザーモデル**

   - バリデーション（name, email）
   - role の enum 定義
   - アソシエーション定義（has_many :posts, :comments, :likes）

3. **ビュー・コントローラー**
   - サインアップページ
   - ログインページ
   - ユーザー登録後のリダイレクト処理

### 実装手順

```bash
# 1. Userモデルのカスタマイズ
# app/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: { general: 0, admin: 1 }

  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, uniqueness: true

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
end

# 2. マイグレーション修正（roleのデフォルト値）
# db/migrate/xxxxx_add_role_to_users.rb
class AddRoleToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :role, :integer, default: 0, null: false
    add_index :users, :role
  end
end

# 3. ビュー生成（カスタマイズ用）
rails generate devise:views
```

### チェックリスト

- [ ] ユーザー登録ができる
- [ ] ログイン・ログアウトができる
- [ ] role が正しく設定される（デフォルト: general）
- [ ] 管理者ユーザーを手動で作成できる（rails console 経由）

---

## 📝 Phase 2: 記事機能（CRUD）

### 実装タスク

1. **Post モデル**

   - バリデーション（title, body）
   - status の enum 定義（draft: 0, published: 1）
   - スコープ定義（published, draft）
   - 公開日時の自動設定（before_save）

2. **PostsController**

   - index（一覧表示、新着順・人気順）
   - show（詳細表示）
   - new/create（新規作成）
   - edit/update（編集）
   - destroy（削除）
   - 認証チェック（before_action）

3. **ビュー**
   - 記事一覧ページ
   - 記事詳細ページ
   - 記事作成・編集フォーム
   - 下書き・公開の切り替え

### 実装手順

```bash
# 1. コントローラー生成
rails generate controller Posts index show new edit

# 2. ルーティング設定
# config/routes.rb
resources :posts
root 'posts#index'

# 3. Postモデル実装
# app/models/post.rb
class Post < ApplicationRecord
  belongs_to :user

  enum status: { draft: 0, published: 1 }

  validates :title, presence: true, length: { maximum: 150 }
  validates :body, presence: true

  scope :published, -> { where(status: :published) }
  scope :recent, -> { order(published_at: :desc) }

  before_save :set_published_at, if: :will_save_change_to_status?

  private

  def set_published_at
    self.published_at = Time.current if published? && published_at.nil?
  end
end
```

### チェックリスト

- [ ] 記事の作成・編集・削除ができる
- [ ] 下書きと公開の切り替えができる
- [ ] 一覧ページで公開記事のみ表示される
- [ ] 自分の記事のみ編集・削除できる
- [ ] 管理者は全記事を編集・削除できる

---

## 📄 Phase 3: Markdown 対応

### 実装タスク

1. **Markdown パーサー設定**

   - redcarpet（または kramdown）の設定
   - ヘルパーメソッドの作成（markdown_to_html）

2. **プレビュー機能**

   - リアルタイムプレビュー（JavaScript）
   - または、プレビューボタンによる表示

3. **スタイリング**
   - Markdown の HTML 出力に対する CSS
   - コードブロックのシンタックスハイライト（オプション）

### 実装手順

```ruby
# 1. ヘルパーメソッド作成
# app/helpers/posts_helper.rb
module PostsHelper
  def markdown_to_html(text)
    renderer = Redcarpet::Render::HTML.new(
      filter_html: true,
      hard_wrap: true,
      link_attributes: { rel: 'nofollow', target: '_blank' }
    )
    markdown = Redcarpet::Markdown.new(renderer, {
      autolink: true,
      tables: true,
      fenced_code_blocks: true
    })
    markdown.render(text).html_safe
  end
end

# 2. ビューで使用
# app/views/posts/show.html.erb
<%= markdown_to_html(@post.body) %>
```

### チェックリスト

- [ ] Markdown が正しく HTML に変換される
- [ ] コードブロックが正しく表示される
- [ ] リンクが正しく動作する
- [ ] プレビュー機能が動作する（実装した場合）

---

## 🖼️ Phase 4: 画像・動画添付

### 実装タスク

1. **ActiveStorage 設定**

   - ストレージ設定（開発環境: local、本番: S3 等）
   - 画像リサイズ設定

2. **Post モデル拡張**

   - has_many_attached :images
   - has_many_attached :videos

3. **ドラッグ&ドロップアップロード機能**

   - ActiveStorage Direct Upload API の設定
   - JavaScript（Stimulus）でドラッグ&ドロップイベント処理
   - アップロード完了後に Markdown エディタに URL を自動挿入
   - アップロード進捗表示

4. **ビュー・コントローラー**

   - ファイルアップロードフォーム
   - 画像・動画の表示
   - ファイル削除機能

### 実装手順

```bash
# 1. ActiveStorageインストール（Phase 0で完了済み）
# rails active_storage:install
# rails db:migrate

# 2. Postモデル拡張
# app/models/post.rb
has_many_attached :images
has_many_attached :videos

# 3. コントローラーでパラメータ許可
# app/controllers/posts_controller.rb
def post_params
  params.require(:post).permit(:title, :body, :status, images: [], videos: [])
end
```

### JavaScript 実装（Stimulus Controller）

```javascript
// app/javascript/controllers/upload_controller.js
import { Controller } from "@hotwired/stimulus";
import { DirectUpload } from "@rails/activestorage";

export default class extends Controller {
  static targets = ["input", "editor"];

  connect() {
    this.element.addEventListener("dragover", this.handleDragOver.bind(this));
    this.element.addEventListener("drop", this.handleDrop.bind(this));
  }

  handleDragOver(e) {
    e.preventDefault();
    e.stopPropagation();
  }

  async handleDrop(e) {
    e.preventDefault();
    e.stopPropagation();

    const files = Array.from(e.dataTransfer.files);
    for (const file of files) {
      if (file.type.startsWith("image/") || file.type.startsWith("video/")) {
        await this.uploadFile(file);
      }
    }
  }

  async uploadFile(file) {
    const upload = new DirectUpload(
      file,
      "/rails/active_storage/direct_uploads"
    );

    upload.create((error, blob) => {
      if (error) {
        console.error("Upload error:", error);
        return;
      }

      const url = `/rails/active_storage/blobs/${blob.signed_id}/${blob.filename}`;
      const markdown = file.type.startsWith("image/")
        ? `![${file.name}](${url})`
        : `[${file.name}](${url})`;

      // MarkdownエディタにURLを挿入
      this.insertMarkdown(markdown);
    });
  }

  insertMarkdown(markdown) {
    const editor = this.editorTarget;
    const start = editor.selectionStart;
    const end = editor.selectionEnd;
    const text = editor.value;
    const newText =
      text.substring(0, start) + markdown + "\n" + text.substring(end);

    editor.value = newText;
    editor.selectionStart = editor.selectionEnd = start + markdown.length + 1;
    editor.focus();
  }
}
```

### ビュー実装例

```erb
<!-- app/views/posts/_form.html.erb -->
<%= form_with model: @post, data: { controller: "upload", upload_editor_target: "editor" } do |f| %>
  <div data-upload-target="input">
    <%= f.text_area :body, class: "markdown-editor" %>
    <p class="upload-hint">画像や動画をドラッグ&ドロップでアップロードできます</p>
  </div>
<% end %>
```

### チェックリスト

- [ ] Post モデルに`has_many_attached :images`と`has_many_attached :videos`を追加
- [ ] コントローラーでパラメータ許可を設定
- [ ] ActiveStorage Direct Upload API が動作する
- [ ] ドラッグ&ドロップでファイルをアップロードできる
- [ ] アップロード完了後に Markdown エディタに URL が自動挿入される
- [ ] 画像が正しく表示される
- [ ] 動画が正しく表示される
- [ ] 下書き保存時もアップロード済みファイルが保持される
- [ ] ファイルサイズ制限が設定されている（オプション）

---

## 💬 Phase 5: コメント機能

### 実装タスク

1. **Comment モデル**

   - バリデーション（content）
   - アソシエーション（belongs_to :post, :user）
   - user_id が NULL 許可（ゲスト対応）

2. **CommentsController**

   - create（コメント作成）
   - destroy（コメント削除）
   - ゲスト対応（user_id が NULL でも作成可能）

3. **ビュー**
   - コメント一覧表示
   - コメント投稿フォーム
   - ゲスト用の名前入力欄

### 実装手順

```bash
# 1. コントローラー生成
rails generate controller Comments create destroy

# 2. ルーティング設定
# config/routes.rb
resources :posts do
  resources :comments, only: [:create, :destroy]
end

# 3. Commentモデル実装
# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user, optional: true

  validates :content, presence: true
end
```

### チェックリスト

- [ ] ログインユーザーがコメント投稿できる
- [ ] ゲストがコメント投稿できる（名前入力）
- [ ] コメント一覧が表示される
- [ ] 自分のコメントを削除できる
- [ ] 管理者が全コメントを削除できる

---

## ❤️ Phase 6: いいね機能

### 実装タスク

1. **Like モデル**

   - バリデーション（重複防止）
   - ユニーク制約（user_id + post_id / guest_identifier + post_id）
   - ゲスト識別子の生成・管理

2. **LikesController**

   - create（いいね追加）
   - destroy（いいね削除）
   - Ajax 対応

3. **ビュー・JavaScript**
   - いいねボタン
   - いいね数の表示
   - Ajax による非同期更新

### 実装手順

```bash
# 1. コントローラー生成
rails generate controller Likes create destroy

# 2. ルーティング設定
# config/routes.rb
resources :posts do
  resources :likes, only: [:create, :destroy]
end

# 3. Likeモデル実装
# app/models/like.rb
class Like < ApplicationRecord
  belongs_to :post
  belongs_to :user, optional: true

  validates :post_id, uniqueness: { scope: :user_id }, if: -> { user_id.present? }
  validates :post_id, uniqueness: { scope: :guest_identifier }, if: -> { guest_identifier.present? }
end
```

### チェックリスト

- [ ] ログインユーザーがいいねできる
- [ ] ゲストがいいねできる（Cookie 識別）
- [ ] 重複いいねが防止される
- [ ] いいね数が正しく表示される
- [ ] Ajax で非同期更新される

---

## 🎨 Phase 7: UI/UX 改善

### 実装タスク

1. **デザイン調整**

   - Bootstrap または Tailwind CSS 導入
   - レイアウトの改善
   - カラースキームの統一

2. **レスポンシブ対応**

   - モバイル表示の最適化
   - タブレット表示の調整

3. **ユーザビリティ向上**
   - ページネーション
   - 検索機能（オプション）
   - ソート機能の改善

### 実装手順

```bash
# 1. CSSフレームワーク導入（例: Bootstrap）
bundle add bootstrap
# または
bundle add tailwindcss-rails

# 2. アセットパイプライン設定
# app/assets/stylesheets/application.css
@import "bootstrap";
```

### チェックリスト

- [ ] デザインが統一されている
- [ ] モバイル表示が最適化されている
- [ ] ページネーションが動作する
- [ ] ユーザビリティが向上している

---

## 🧪 Phase 8: テスト・品質保証

### 実装タスク

1. **RSpec 設定**

   - テスト環境の設定
   - FactoryBot 設定
   - テストヘルパーの作成

2. **モデルテスト**

   - User モデルのテスト
   - Post モデルのテスト
   - Comment モデルのテスト
   - Like モデルのテスト

3. **コントローラーテスト**

   - PostsController のテスト
   - CommentsController のテスト
   - LikesController のテスト

4. **システムテスト**
   - 主要なユーザーフローのテスト

### 実装手順

```bash
# 1. RSpec初期化（Phase 0で実施済み）
# 2. FactoryBot設定
# spec/rails_helper.rb
config.include FactoryBot::Syntax::Methods

# 3. ファクトリー作成
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { 'password123' }
    role { :general }
  end
end
```

### チェックリスト

- [ ] モデルテストが作成されている
- [ ] コントローラーテストが作成されている
- [ ] システムテストが作成されている
- [ ] テストカバレッジが 80%以上（目標）

---

## 🚢 Phase 9: デプロイ準備

### 実装タスク

1. **本番環境設定**

   - データベース設定（PostgreSQL 推奨）
   - 環境変数の設定
   - セキュリティ設定

2. **デプロイ設定**

   - Heroku / Render / AWS 等の選択
   - デプロイスクリプトの作成
   - 本番環境での動作確認

3. **セキュリティ対策**
   - パスワードポリシー
   - CSRF 対策の確認
   - SQL インジェクション対策の確認

### 実装手順

```bash
# 1. 本番環境用Gem追加
# Gemfile
gem 'pg'  # PostgreSQL用

# 2. 環境変数設定
# config/application.yml（dotenv-rails使用）
PRODUCTION_DATABASE_URL: <%= ENV['DATABASE_URL'] %>

# 3. デプロイ（Heroku例）
heroku create my-blog-app
git push heroku main
heroku run rails db:migrate
```

### チェックリスト

- [ ] 本番環境で正常に動作する
- [ ] データベースが正しく設定されている
- [ ] セキュリティ設定が適切である
- [ ] エラーログの監視が設定されている

---

## 📊 進捗管理

### 推奨ツール

- GitHub Issues / Projects（タスク管理）
- チェックリスト（各フェーズの完了確認）
- コミットメッセージの統一（例: `[Phase 1] Add user authentication`）

### 進捗確認方法

各フェーズ終了時に以下を確認：

1. 機能が正常に動作する
2. チェックリストがすべて完了している
3. コードレビュー（自己レビュー）を実施
4. 次のフェーズに進む前にコミット・プッシュ

---

## 🔄 将来の拡張（Phase 10 以降）

以下の機能は MVP 完了後に実装を検討：

- **タグ機能**: 記事へのタグ付け、タグ検索
- **通知機能**: コメント・いいね通知
- **プロフィール機能**: ユーザーアイコン、自己紹介
- **API モード化**: React / Flutter Web フロント実装
- **全文検索**: Elasticsearch 等の導入
- **スパム対策**: reCAPTCHA 導入

---

## 📝 注意事項

1. **段階的な実装**: 一度にすべてを実装せず、フェーズごとに動作確認
2. **テスト駆動開発**: 可能な限りテストを先に書く（TDD）
3. **コード品質**: RuboCop 等でコードスタイルを統一
4. **セキュリティ**: 各フェーズでセキュリティを意識した実装
5. **ドキュメント**: 実装内容は適宜ドキュメント化

---

## 🎯 成功基準

MVP 完了の定義：

- [ ] すべての基本機能が動作する
- [ ] テストカバレッジが 80%以上
- [ ] 本番環境で正常に動作する
- [ ] セキュリティ対策が実施されている
- [ ] 基本的な UI/UX が整っている

---

**最終更新日**: 2025 年
**作成者**: 開発チーム
