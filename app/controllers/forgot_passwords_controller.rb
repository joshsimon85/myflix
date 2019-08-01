class ForgotPasswordsController < ApplicationController
  def new; end

  def create
    user = User.find_by(email: params[:email])
    if user
      AppMailer.send_forgot_password(user).deliver
      redirect_to forgot_password_confirmation_path
    else
      flash[:error] = "Email can't be blank"
      redirect_to forgot_passwords_path
    end
  end
end
