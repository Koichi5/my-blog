class CreateLikes < ActiveRecord::Migration[7.2]
  def change
    create_table :likes do |t|
      t.references :post, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.string :guest_identifier, limit: 64

      t.timestamps
    end

    add_index :likes, :guest_identifier
    # Note: index on user_id is automatically created by t.references
    # Note: Unique constraints for user_id+post_id and guest_identifier+post_id
    # will be enforced at the model level due to SQLite limitations
  end
end
