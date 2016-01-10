Fabricator(:file_system) do
  team { Fabricate(:team) }
  channel { Faker::Lorem.word }
end
