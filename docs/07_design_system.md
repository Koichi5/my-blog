# MyBlogApp デザインシステム

SmartHR Design System を参考にした、MyBlogApp 用のシンプルなデザインシステムです。一貫した UX と拡張の土台を提供します。

---

## 基本原則

- **一貫性**: 色・余白・タイポグラフィをトークンで統一し、画面間で同じルールを使う。
- **アクセシビリティ**: 誰でも使えるよう、コントラスト・フォーカス・セマンティック HTML を意識する。
- **拡張しやすさ**: デザイントークンと共有パーシャルを一箇所で管理し、変更時の影響範囲を把握しやすくする。

---

## デザイントークン

トークンは [app/assets/tailwind/application.css](app/assets/tailwind/application.css) の `@theme` で定義しています。Tailwind のビルド後に `bg-*` / `text-*` 等のユーティリティとして利用できます。

### 色（セマンティック）

| トークン名 | 用途 | Tailwind クラス例 |
|-----------|------|-------------------|
| primary | リンク・メイン CTA | `bg-primary`, `text-primary` |
| primary-hover | プライマリのホバー | `hover:bg-primary-hover` |
| success | 成功メッセージ（枠・テキスト） | `border-success`, `text-success-text` |
| success-bg | 成功メッセージ背景 | `bg-success-bg` |
| danger | エラー・削除 | `bg-danger`, `text-danger`, `border-danger` |
| danger-hover | 危険ボタンのホバー | `hover:bg-danger-hover` |
| danger-bg / danger-text | エラーアラート | `bg-danger-bg`, `text-danger-text` |
| background | ページ背景 | `bg-background` |
| surface | カード・パネル背景 | `bg-surface` |
| border / border-subtle | 枠線・区切り | `border-border`, `bg-border-subtle` |
| text | 本文 | `text-text` |
| text-muted / text-muted-light | 補助テキスト | `text-text-muted` |

### タイポグラフィ

`@theme` 内で `--font-size-heading-1`（2.25rem）, `--font-size-heading-2`（1.5rem）, `--font-size-heading-3`（1.25rem）, `--font-weight-bold`（700）, `--font-weight-semibold`（600）, `--font-weight-medium`（500）を定義。見出しは既存の `text-4xl` / `text-2xl` / `text-xl` と組み合わせて利用。

### スペーシング・レイアウト

- カードの余白: `p-8`（トークン `--spacing-card` に相当）
- 角丸: カード `rounded-lg`、ボタン `rounded-md`
- コンテナ: `max-w-7xl`（`--container-max` に相当）

---

## コンポーネント

### アラート（フラッシュメッセージ）

**パーシャル**: `shared/alert`  
**Locals**: `type`（`:notice` | `:alert`）, `message`

```erb
<%= render "shared/alert", type: :notice, message: notice %>
<%= render "shared/alert", type: :alert, message: alert %>
```

### カード

**パーシャル**: `shared/card`  
**Locals**: `title`（任意）, `content`（必須）, `extra_class`（任意）

```erb
<%= render "shared/card", title: "コメント", content: capture do %>
  ... 中身 ...
<% end %>
```

### ボタン（リンク）

**パーシャル**: `shared/button_link`  
**Locals**: `url`, `label`, `variant`（`:primary` | `:secondary` | `:danger` | `:link`）, `method`, `data`, `class_extra`

```erb
<%= render "shared/button_link", url: new_post_path, label: "新規投稿", variant: :primary %>
```

**ヘルパー**（`link_to` / `button_to` にクラスだけ渡す場合）:

```erb
<%= link_to "編集", edit_post_path(@post), class: ds_button_classes(:link) %>
<%= button_to "削除", post_path(@post), method: :delete, class: ds_button_classes(:danger) %>
```

### フォームフィールド

**パーシャル**: `shared/form_field`  
**Locals**: `form`（f）, `field_name`, `label_text`（任意）, `input_html`（入力要素の HTML）

```erb
<%= render "shared/form_field", form: f, field_name: :title, label_text: "タイトル", input_html: f.text_field(:title, class: ds_input_classes) %>
```

**ヘルパー**: `ds_form_field_classes`（ラベル用）, `ds_input_classes`（input / textarea 用）

---

## アクセシビリティ（簡易チェックリスト）

- **コントラスト**: 本文・ボタンは背景とのコントラスト比を十分に（WCAG 2.1 レベル AA を目安）。
- **フォーカス**: キーボード操作時にフォーカスが分かるようにする（`focus:ring-2` 等を使用）。
- **セマンティック HTML**: 見出しは `h1`〜`h3`、フラッシュは `role="alert"` を付与。
- **フォーム**: ラベルと入力の対応（`label` の `for` と `id`）、エラー表示の関連付け。

---

## Phase 7（UI/UX 改善）との関係

[docs/06_implementation_plan.md](docs/06_implementation_plan.md) の Phase 7 では「デザインの統一」「カラースキームの統一」がタスクに含まれています。本デザインシステムの導入により、トークンとコンポーネントでそれらを満たしています。ページネーション・検索等は別タスクとして実装してください。
