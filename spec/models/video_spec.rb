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

describe '#rating' do
  it 'should return nil if there are no ratings' do
    video = Video.create(title: 'South Park', description: 'A comedy')
    expect(video.rating).to be_nil
  end

  it 'should return the average of all ratings' do
    video = Video.create(title: 'South Park', description: 'A comedy')
    review = Review.create(full_name: 'Jane Doe', body: Faker::Lorem.paragraph(2), rating: Faker::Number.between(1, 5), user_id: 1, video_id: video.id)
    review_2 = Review.create(full_name: 'Jane Doe', body: Faker::Lorem.paragraph(2), rating: Faker::Number.between(1, 5), user_id: 2, video_id: video.id)
    expect(video.rating).to eq((review.rating + review_2.rating) / 2.0)
  end

  it 'should return a decimal rating when the rating is not a whole number 4.2' do
    video = Video.create(title: 'South Park', description: 'A comedy')
    review = Review.create(full_name: 'Jane Doe', body: Faker::Lorem.paragraph(2), rating: Faker::Number.between(1, 5), user_id: 1, video_id: video.id)
    review_2 = Review.create(full_name: 'Jane Doe', body: Faker::Lorem.paragraph(2), rating: Faker::Number.between(1, 5), user_id: 2, video_id: video.id)
    expect(video.rating).to eq((review.rating + review_2.rating) / 2.0)
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

describe ".search", :elasticsearch do
  let(:refresh_index) do
    Video.import
    Video.__elasticsearch__.refresh_index!
  end

  context "with title" do
    it "returns no results when there's no match" do
      Fabricate(:video, title: "Futurama")
      refresh_index

      expect(Video.search("whatever").records.to_a).to eq []
    end

    it "returns an empty array when there's no search term" do
      futurama = Fabricate(:video)
      south_park = Fabricate(:video)
      refresh_index

      expect(Video.search("").records.to_a).to eq []
    end

    it "returns an array of 1 video for title case insensitve match" do
      futurama = Fabricate(:video, title: "Futurama")
      south_park = Fabricate(:video, title: "South Park")
      refresh_index

      expect(Video.search("futurama").records.to_a).to eq [futurama]
    end

    it "returns an array of many videos for title match" do
      star_trek = Fabricate(:video, title: "Star Trek")
      star_wars = Fabricate(:video, title: "Star Wars")
      refresh_index

      expect(Video.search("star").records.to_a).to match_array [star_trek, star_wars]
    end
  end

  context "with title and description" do
    it "returns an array of many videos based for title and description match" do
      star_wars = Fabricate(:video, title: "Star Wars")
      about_sun = Fabricate(:video, description: "sun is a star")
      refresh_index

      expect(Video.search("star").records.to_a).to match_array [star_wars, about_sun]
    end
  end

  context "multiple words must match" do
    it "returns an array of videos where 2 words match title" do
      star_wars_1 = Fabricate(:video, title: "Star Wars: Episode 1")
      star_wars_2 = Fabricate(:video, title: "Star Wars: Episode 2")
      bride_wars = Fabricate(:video, title: "Bride Wars")
      star_trek = Fabricate(:video, title: "Star Trek")
      refresh_index

      expect(Video.search("Star Wars").records.to_a).to match_array [star_wars_1, star_wars_2]
    end
  end
end
