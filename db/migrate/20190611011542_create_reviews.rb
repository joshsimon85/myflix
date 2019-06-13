class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.string :full_name
      t.text :body
      t.integer :rating
      t.timestamps
    end
  end
end
