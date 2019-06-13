require 'spec_helper'

describe Video, type: :model do
  it { should belong_to :category }
  it { should validate_presence_of :title }
  it { should validate_presence_of :description }
end

describe '#search_by_title' do
  it 'should return and empty list if no matches' do
    video = Video.create(title: 'South Park', description: 'A comedey')
    expect(Video.search_by_title('Monk')).to eq([])
  end

  it 'should return a list with one match' do
    video = Video.create(title: 'South Park', description: 'A comedey')
    expect(Video.search_by_title('South Park')).to eq([video])
  end

  it 'should return a list with a partial title match' do
    video = Video.create(title: 'South Park', description: 'A comedey')
    expect(Video.search_by_title('out')).to eq([video])
  end

  it 'should return a list with multiple matches ordered by created_on' do
    video_1 = Video.create(title: 'South Park', description: 'A comedy')
    video_2 = Video.create(title: 'South down', description: 'A horror')
    expect(Video.search_by_title('South')).to eq([video_2, video_1])
  end

  it 'should return an empty list if search term is an empty string' do
    video_1 = Video.create(title: 'South Park', description: 'A comedy')
    video_2 = Video.create(title: 'South down', description: 'A horror')
    expect(Video.search_by_title('')).to eq([])
  end
end

describe '#average_rating' do
  it 'should return 5.0 if there are no ratings' do
    video = Video.create(title: 'South Park', description: 'A comedy')
    expect(video.average_rating).to eq(5.0)
  end

  it 'should return the average of all ratings' do
    video = Video.create(title: 'South Park', description: 'A comedy')
    review = Review.create(full_name: 'Jane Doe', body: Faker::Lorem.paragraph(2), rating: Faker::Number.between(1, 5), user_id: 1, video_id: video.id)
    review_2 = Review.create(full_name: 'Jane Doe', body: Faker::Lorem.paragraph(2), rating: Faker::Number.between(1, 5), user_id: 2, video_id: video.id)
    expect(video.average_rating).to eq((review.rating + review_2.rating) / 2.0)
  end

  it 'should return a decimal rating when the rating is not a whole number 4.2' do
    video = Video.create(title: 'South Park', description: 'A comedy')
    review = Review.create(full_name: 'Jane Doe', body: Faker::Lorem.paragraph(2), rating: Faker::Number.between(1, 5), user_id: 1, video_id: video.id)
    review_2 = Review.create(full_name: 'Jane Doe', body: Faker::Lorem.paragraph(2), rating: Faker::Number.between(1, 5), user_id: 2, video_id: video.id)
    expect(video.average_rating).to eq((review.rating + review_2.rating) / 2.0)
  end
end

describe '#total_reviews' do
  it 'should return 0 if there are no reviews for a given video' do
    video = Video.create(title: 'South Park', description: 'A comedy')
    expect(video.total_reviews).to eq(0)
  end

  it 'should return the total number of reviews for a given video' do
    video = Video.create(title: 'South Park', description: 'A comedy')
    review = Review.create(full_name: 'Jane Doe', body: Faker::Lorem.paragraph(2), rating: Faker::Number.between(1, 5), user_id: 1, video_id: video.id)
    review_2 = Review.create(full_name: 'Jane Doe', body: Faker::Lorem.paragraph(2), rating: Faker::Number.between(1, 5), user_id: 2, video_id: video.id)
    expect(video.total_reviews).to eq(2)
  end
end
