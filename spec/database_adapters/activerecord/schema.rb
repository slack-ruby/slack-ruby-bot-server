require_relative 'activerecord'

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :teams, force: true do |t|
    t.string :team_id
    t.string :name
    t.string :domain
    t.string :token
    t.string :bot_user_id
    t.string :activated_user_id
    t.string :activated_user_access_token
    t.boolean :active, default: true

    t.timestamps
  end
end
