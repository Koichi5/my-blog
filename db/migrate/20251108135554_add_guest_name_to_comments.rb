class AddGuestNameToComments < ActiveRecord::Migration[7.2]
  def change
    add_column :comments, :guest_name, :string
  end
end
