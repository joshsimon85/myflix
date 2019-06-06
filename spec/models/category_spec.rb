require 'spec_helper'

describe Category, type: :model do
  it { should have_many :videos }
end

describe '#recent_videos' do
  it 'should return an empty list if there are no matches under that category' do
    comedy = Category.create(name: 'comedy')
    expect(comedy.recent_videos).to eq([])
  end

  it 'should return a list of of one if there is one video in the category' do
    comedy = Category.create(name: 'comedy')
    drama = Category.create(name: 'drama')
    video_1 = Video.create(title: 'monk', description: 'A comedy', category: comedy)
    video_2 = Video.create(title: 'futurama', description: 'A drama', category: drama)
    expect(comedy.recent_videos).to eq([video_1])
  end

  it 'should return a list of six ordered by created_on with the most recent first' do
    comedy = Category.create(name: 'comedy')
    video_1 = Video.create(title: 'monk', description: 'comedy', category: comedy, created_at: Time.new(2000))
    video_2 = Video.create(title: 'simpsons', description: 'comedy', category: comedy, created_at: Time.new(2001))
    video_3 = Video.create(title: 'futurama', description: 'comedy', category: comedy, created_at: Time.new(2003))
    video_4 = Video.create(title: 'king of the hill', description: 'comedy', category: comedy, created_at: Time.new(2004))
    video_5 = Video.create(title: 'that 70s show', description: 'comedy', category: comedy, created_at: Time.new(2005))
    video_6 = Video.create(title: 'life', description: 'comedy', category: comedy, created_at: Time.new(2006))
    video_7 = Video.create(title: 'cemex', description: 'A comedy', category: comedy, created_at: Time.new(2007))
    expect(comedy.recent_videos).to eq([video_7, video_6, video_5, video_4, video_3, video_2])
  end
end
