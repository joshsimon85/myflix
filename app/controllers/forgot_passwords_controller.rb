class ForgotPasswordsController < ApplicationController
  def new; end

  def create
    user = User.find_by(email: params[:email])
    if user
      AppMailer.delay.send_forgot_password(user.id)
      redirect_to forgot_password_confirmation_path
    else
      flash[:error] = params[:email].blank? ? "Email can't be blank" : 'There is no user with that email in the system'
      redirect_to forgot_password_path
    end
  end

end
