class CategoriesController < ApplicationController
  def show
    @category = params[:id]
    @videos = Category.find_by("name = ?", @category).videos
  end
end
