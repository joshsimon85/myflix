Fabricator(:review) do
  full_name { Faker::Name.name }
  body { Faker::Lorem.paragraph(3) }
  rating { Faker::Number.between(1, 5) }
  created_at { Faker::Date.backward((1..100).to_a.sample) }
end
