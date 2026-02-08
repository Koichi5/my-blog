class CreatePosts < ActiveRecord::Migration[7.2]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false, limit: 150
      t.text :body, null: false
      t.integer :status, null: false, default: 0
      t.datetime :published_at

      t.timestamps
    end

    add_index :posts, :status
    add_index :posts, :published_at
  end
end
