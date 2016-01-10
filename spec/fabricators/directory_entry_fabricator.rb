Fabricator(:directory_entry) do
  parent_directory_entry { (FileSystem.first || Fabricate(:file_system)).root_directory_entry }
  name { Faker::Lorem.word }
end
