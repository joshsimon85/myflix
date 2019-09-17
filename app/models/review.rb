class Review < ActiveRecord::Base
  default_scope { order(created_at: :desc) }

  belongs_to :video, touch: true
  belongs_to :user

  validates_presence_of :body, :rating
end
