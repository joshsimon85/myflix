class Admin::VideosController < AdminsController
  def new
    @video = Video.new
  end

  def create
    @video = Video.create(video_params)
    if @video.save
      flash[:success] = "You have sucessfully added #{@video.title}"
      redirect_to new_admin_video_path
    else
      flash.now[:error] = "You can't add this video, please check the errors"
      render :new
    end
  end

  private

  def video_params
    params.require(:video).permit!
  end
end
