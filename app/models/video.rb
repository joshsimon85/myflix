class Video < ActiveRecord::Base
  belongs_to :category
  has_many :reviews
  validates_presence_of :title, :description

  def self.search_by_title(title)
    return [] if title.blank?

    where('title ~* ?', title).order(created_at: :desc)
  end

  def average_rating
    return 5.0 if reviews.size == 0
    average = reviews.map{ |review| review.rating }.reduce(&:+) / (reviews.size.to_f)
  end

  def total_reviews
    self.reviews.count
  end
end
