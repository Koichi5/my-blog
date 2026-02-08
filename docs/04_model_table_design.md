# 🗂 テーブル設計書（MVP）

## 🧍‍♂️ users テーブル

| カラム名           | 型          | 制約             | デフォルト | 説明                             |
| ------------------ | ----------- | ---------------- | ---------- | -------------------------------- |
| id                 | bigint      | PK               |            | ユーザー ID                      |
| name               | string(50)  | NOT NULL         |            | 表示名                           |
| email              | string(255) | NOT NULL, UNIQUE |            | Devise 認証用メールアドレス      |
| encrypted_password | string(255) | NOT NULL         |            | Devise 用パスワードハッシュ      |
| role               | integer     | NOT NULL         | `0`        | enum: `{ general: 0, admin: 1 }` |
| created_at         | datetime    | NOT NULL         |            |                                  |
| updated_at         | datetime    | NOT NULL         |            |                                  |

**Index**

- `index_users_on_email`（UNIQUE）
- `index_users_on_role`

**備考**

- Devise により自動生成されるカラム（`reset_password_token`, `remember_created_at`など）は省略可。
- enum により管理者権限を区別。

---

## 📝 posts テーブル

| カラム名     | 型          | 制約          | デフォルト | 説明                                |
| ------------ | ----------- | ------------- | ---------- | ----------------------------------- |
| id           | bigint      | PK            |            | 記事 ID                             |
| user_id      | bigint      | FK (users.id) |            | 投稿者                              |
| title        | string(150) | NOT NULL      |            | 記事タイトル                        |
| body         | text        | NOT NULL      |            | Markdown 本文                       |
| status       | integer     | NOT NULL      | `0`        | enum: `{ draft: 0, published: 1 }`  |
| published_at | datetime    |               |            | 公開日時（status=published 時のみ） |
| created_at   | datetime    | NOT NULL      |            |                                     |
| updated_at   | datetime    | NOT NULL      |            |                                     |

**Index**

- `index_posts_on_user_id`
- `index_posts_on_status`
- `index_posts_on_published_at`

**備考**

- ActiveStorage で画像や動画を添付可能。
- 下書き（draft）状態の記事は一覧に表示しない。

---

## 💬 comments テーブル

| カラム名   | 型       | 制約                     | デフォルト | 説明                      |
| ---------- | -------- | ------------------------ | ---------- | ------------------------- |
| id         | bigint   | PK                       |            | コメント ID               |
| post_id    | bigint   | FK (posts.id)            |            | 対象記事                  |
| user_id    | bigint   | FK (users.id), NULL 許可 |            | 投稿者（ゲスト時は NULL） |
| content    | text     | NOT NULL                 |            | コメント本文              |
| created_at | datetime | NOT NULL                 |            |                           |
| updated_at | datetime | NOT NULL                 |            |                           |

**Index**

- `index_comments_on_post_id`
- `index_comments_on_user_id`

**備考**

- 将来的にスパム対策のため、コメント送信制限や reCAPTCHA 導入を想定。
- 投稿者が削除された場合、`user_id`は NULL に設定する（`dependent: :nullify`）。

---

## ❤️ likes テーブル

| カラム名         | 型         | 制約                     | デフォルト | 説明                        |
| ---------------- | ---------- | ------------------------ | ---------- | --------------------------- |
| id               | bigint     | PK                       |            | いいね ID                   |
| post_id          | bigint     | FK (posts.id)            |            | 対象記事                    |
| user_id          | bigint     | FK (users.id), NULL 許可 |            | いいねしたユーザー          |
| guest_identifier | string(64) | NULL 許可                |            | ゲスト識別用（Cookie など） |
| created_at       | datetime   | NOT NULL                 |            |                             |

**Index**

- `index_likes_on_post_id`
- `index_likes_on_user_id`
- `index_likes_on_guest_identifier`
- `index_likes_on_user_id_and_post_id`（UNIQUE）
- `index_likes_on_guest_identifier_and_post_id`（UNIQUE）

**備考**

- ユーザー・ゲストともに同一記事への重複いいねを防止する。
- ゲスト識別子は Cookie 等で発行。

---

## 🔗 外部キー制約まとめ

| テーブル | 外部キー | 参照先    | オプション         |
| -------- | -------- | --------- | ------------------ |
| posts    | user_id  | users(id) | ON DELETE CASCADE  |
| comments | post_id  | posts(id) | ON DELETE CASCADE  |
| comments | user_id  | users(id) | ON DELETE SET NULL |
| likes    | post_id  | posts(id) | ON DELETE CASCADE  |
| likes    | user_id  | users(id) | ON DELETE SET NULL |

---

## 🔒 データ整合性・制約の方針

| 区分                 | 方針                                                                        |
| -------------------- | --------------------------------------------------------------------------- |
| **NULL 制約**        | 論理的に必須の項目には NOT NULL を設定（例：title, body, content）          |
| **UNIQUE 制約**      | email, いいねの組み合わせ（user_id + post_id / guest_identifier + post_id） |
| **外部キー制約**     | すべて明示的に設定（DB レベルで整合性保証）                                 |
| **依存削除**         | Post 削除時に Comment, Like も削除（`dependent: :destroy`）                 |
| **インデックス設計** | 検索・並び替えで利用されるカラムに付与（status, published_at など）         |

---

## 🧱 将来的な追加テーブル（拡張）

| テーブル          | 用途                                              |
| ----------------- | ------------------------------------------------- |
| **tags**          | 記事タグ管理（name 列のみ）                       |
| **post_tags**     | 中間テーブル（post_id, tag_id）                   |
| **notifications** | コメントやいいねの通知（後続フェーズ）            |
| **profiles**      | User の拡張プロフィール（アイコン・自己紹介など） |

---
