Fabricator(:vi_program, class_name: 'ViProgram', from: :program) do
  filename { Faker::Lorem.word + '.txt' }
end
