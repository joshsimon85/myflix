class Video < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  index_name ['myflix', Rails.env].join('_')
  document_type 'video'

  belongs_to :category
  has_many :reviews

  mount_uploader :large_cover, LargeCoverUploader
  mount_uploader :small_cover, SmallCoverUploader

  validates_presence_of :title, :description

  def self.search_by_title(title)
    return [] if title.blank?

    where('title ~* ?', title).order(created_at: :desc)
  end

  def rating
    return nil if reviews.size == 0
    average = reviews.map{ |review| review.rating }.reduce(&:+) / (reviews.size.to_f)
  end

  def total_reviews
    self.reviews.count
  end

  def self.search(query)
    search_definition = {
      query: {
        multi_match: {
          query: query,
          fields: ['title', 'description'],
          operator: 'and',
        }
      }
    }
    __elasticsearch__.search(search_definition)
  end

  def as_indexed_json(options={})
    as_json(only: [:title, :description])
  end
end
