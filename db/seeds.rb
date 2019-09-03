Category.create(name: 'horror')
Category.create(name: 'comedy')
Category.create(name: 'drama')
Category.create(name: 'action')

Video.create(
  title: 'Family Guy',
  small_cover: '/tmp/family_guy.jpg',
  large_cover: '/tmp/monk_large.jpg',
  description: 'Family Guy is an animated tv series.',
  category_id: [1, 2, 3, 4].sample
)

Video.create(
  title: 'Futurama',
  small_cover: '/tmp/futurama.jpg',
  large_cover: '/tmp/monk_large.jpg',
  description: 'Futurama is an animated comedy tv series.',
  category_id: [1, 2, 3, 4].sample
)

Video.create(
  title: 'South Park',
  small_cover: '/tmp/south_park.jpg',
  large_cover: '/tmp/monk_large.jpg',
  description: 'South Park is an animated comedy tv series.',
  category_id: [1, 2, 3, 4].sample

)

Video.create(
  title: 'Family Guy',
  small_cover: '/tmp/family_guy.jpg',
  large_cover: '/tmp/monk_large.jpg',
  description: 'Family Guy is an animated tv series.',
  category_id: [1, 2, 3, 4].sample
)

Video.create(
  title: 'Futurama',
  small_cover: '/tmp/futurama.jpg',
  large_cover: '/tmp/monk_large.jpg',
  description: 'Futurama is an animated comedy tv series.',
  category_id: [1, 2, 3, 4].sample
)

Video.create(
  title: 'South Park',
  small_cover: '/tmp/south_park.jpg',
  large_cover: '/tmp/monk_large.jpg',
  description: 'South Park is an animated comedy tv series.',
  category_id: 1
)

Video.create(
  title: 'Family Guy',
  small_cover: '/tmp/family_guy.jpg',
  large_cover: '/tmp/monk_large.jpg',
  description: 'Family Guy is an animated tv series.',
  category_id: 1
)

Video.create(
  title: 'Futurama',
  small_cover: '/tmp/futurama.jpg',
  large_cover: '/tmp/monk_large.jpg',
  description: 'Futurama is an animated comedy tv series.',
  category_id: 1
)

Video.create(
  title: 'South Park',
  small_cover: '/tmp/south_park.jpg',
  large_cover: '/tmp/monk_large.jpg',
  description: 'South Park is an animated comedy tv series.',
  category_id: 1
)

Video.create(
  title: 'Family Guy',
  small_cover: '/tmp/family_guy.jpg',
  large_cover: '/tmp/monk_large.jpg',
  description: 'Family Guy is an animated tv series.',
  category_id: 1
)

Video.create(
  title: 'Futurama',
  small_cover: '/tmp/futurama.jpg',
  large_cover: '/tmp/monk_large.jpg',
  description: 'Futurama is an animated comedy tv series.',
  category_id: 1
)

Video.create(
  title: 'South Park',
  small_cover: '/tmp/south_park.jpg',
  large_cover: '/tmp/monk_large.jpg',
  description: 'South Park is an animated comedy tv series.',
  category_id: 1
)

jon = User.create(
  email: 'jon@doe.com',
  full_name: 'Jon Doe',
  password: 'password',
  admin: true
)

jane = User.create(
  email: 'jane@doe.com',
  full_name: 'Jane Doe',
  password: 'password'
)

alice = User.create(
  email: 'alice@doe.com',
  full_name: 'Alice Doe',
  password: 'password'
)

Review.create(
  full_name: User.first.full_name,
  body: Faker::Lorem.paragraph(3),
  rating: Faker::Number.between(1, 5),
  video_id: Video.first.id,
  user_id: User.first.id,
)

Review.create(
  full_name: User.second.full_name,
  body: Faker::Lorem.paragraph(3),
  rating: Faker::Number.between(1, 5),
  video_id: Video.first.id,
  user_id: User.second.id,
)

Review.create(
  full_name: User.first.full_name,
  body: Faker::Lorem.paragraph(3),
  rating: Faker::Number.between(1, 5),
  video_id: Video.second.id,
  user_id: User.first.id
)

Review.create(
  full_name: User.second.full_name,
  body: Faker::Lorem.paragraph(3),
  rating: Faker::Number.between(1, 5),
  video_id: Video.second.id,
  user_id: User.second.id
)

Relationship.create(follower_id: jane.id , leader_id: jon.id)

Relationship.create(follower_id: alice.id, leader_id: jon.id)

Relationship.create(follower_id: jon.id, leader_id: jane.id)

Relationship.create(follower_id: jon.id, leader_id: alice.id)
