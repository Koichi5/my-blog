## 🔒 ⑤ 開発ポリシー・次のステップ (`05_dev_policy_next_steps.md`)
```markdown
# 🔒 データ整合性ポリシー & 開発ステップ

## データ整合性ポリシー

| 種別 | 方針 |
|------|------|
| NULL制約 | 論理的に必須な項目はNOT NULL |
| UNIQUE制約 | email、いいねの組み合わせ制約 |
| 外部キー制約 | 明示的に設定しDBレベルで整合性保証 |
| 削除ポリシー | Post削除時はComment・Likeを削除（`dependent: :destroy`） |
| インデックス | 検索・ソート対象（status, published_atなど）に付与 |

---

## 今後の開発ステップ

1. **Railsプロジェクト作成**
   ```bash
   rails new my_blog_app
````

* Viewモード（APIモードなし）で作成
* DBは PostgreSQL を使用

2. **モデルとマイグレーション作成**

   ```bash
   rails g model User name:string email:string ...
   rails g model Post title:string body:text ...
   ```

3. **アソシエーション・バリデーション定義**

4. **CRUD実装（View + Controller）**

5. **Markdown対応（gem: redcarpet or kramdown）**

6. **ActiveStorage導入（画像・動画添付）**

7. **RSpec導入によるテスト自動化**

8. **APIモード化・フロントエンド連携（将来）**

```

---
