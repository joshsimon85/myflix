class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  Sidekiq::Extensions.enable_delay!

  before_action :set_raven_context

  def require_user
    redirect_to sign_in_path unless current_user
  end

  def current_user
    User.find(session[:user_id]) if session[:user_id]
  end

  helper_method :current_user

  private

  def set_raven_context
    Raven.user_context(id: session[:current_user_id]) # or anything else in session
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
end
