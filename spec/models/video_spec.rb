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
