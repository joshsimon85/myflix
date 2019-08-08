class GenerateAdminBooleanForJonDoe < ActiveRecord::Migration
  def change
    User.find_by(full_name: 'Jon Doe').update_column(:admin, true)
  end
end
