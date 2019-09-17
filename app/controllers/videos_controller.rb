class VideosController < ApplicationController
  before_filter :require_user

  def index
    @categories = Category.all
  end

  def show
    @video = VideoDecorator.decorate(Video.find(params[:id]))
    @reviews = @video.reviews.limit(10)
  end

  def search
    @videos = Video.search_by_title(params[:query])
  end

  def advanced_search
    options = {
      reviews: params[:reviews],
      rating_from: params[:rating_from],
      rating_to: params[:rating_to]
    }

    if params[:query]
      @videos =  Video.search(params[:query], options).records.to_a
    else
      @videos = []
    end
  end
end
