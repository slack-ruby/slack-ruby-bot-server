ActiveRecord::Schema.define do
  self.verbose = false

  create_table :teams, force: true do |t|
    t.integer :team_id
    t.string :name
    t.boolean :active
    t.string :domain
    t.string :token

    t.timestamps
  end
end
