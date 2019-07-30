class User < ActiveRecord::Base
  has_many :reviews, -> { order(created_at: :desc)}
  has_many :queue_items, -> { order(:position) }
  has_many :following_relationships, class_name: 'Relationship', foreign_key: :follower_id
  has_secure_password validations: false
  validates_presence_of :email, :full_name, :password
  validates_uniqueness_of :email

  def normalize_queue_item_positions
    queue_items.each_with_index do |queue_item, index|
      queue_item.update_attributes(position: index + 1)
    end
  end

  def queued_video?(video)
    queue_items.map(&:video).include?(video)
  end
end
