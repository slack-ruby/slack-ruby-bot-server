class AddActivatedFields < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :bot_user_id, :string
    add_column :teams, :activated_user_id, :string
    add_column :teams, :activated_user_access_token, :string
  end
end
