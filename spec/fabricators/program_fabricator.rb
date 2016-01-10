Fabricator(:program) do
  file_system { FileSystem.first || Fabricate(:file_system) }
end
