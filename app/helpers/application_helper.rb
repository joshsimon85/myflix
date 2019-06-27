module ApplicationHelper
  def format_rating(rating)
    sprintf('%.1f', rating)
  end

  def options_for_video_reviews(selected=nil)
    options_for_select((1..5).map do |num|
      [pluralize(num, 'Star'), num ]
    end, selected)
  end
end
