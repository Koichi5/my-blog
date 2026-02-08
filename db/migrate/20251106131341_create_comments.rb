class CreateComments < ActiveRecord::Migration[7.2]
  def change
    create_table :comments do |t|
      t.references :post, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.text :content, null: false

      t.timestamps
    end
    # Note: index on user_id is automatically created by t.references
  end
end
