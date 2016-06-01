Fabricator(:team) do
  token { Fabricate.sequence(:team_token) { |i| "abc-#{i}" } }
  team_id { Fabricate.sequence(:team_id) { |i| "T#{i}" } }
  name { Faker::Lorem.word }
end
