class UsersController < ApplicationController
  before_filter :require_user, only: :show

  def index; end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.valid?
      handle_invitation
      charge = StripeWrapper::Charge.create({
        amount: 999,
        card: params[:stripeToken],
        description: "Sign up charge for #{@user.email}"
      })

      if charge.successful?
        @user.save
        AppMailer.delay.send_welcome_email(@user.id)
        flash[:notice] = 'You have registered'
        redirect_to sign_in_path
      else
        flash[:error] = charge.error_message
        render :new
      end
    else
      render 'new'
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def new_with_invitation_token
    invitation = Invitation.where(token: params[:token]).first
    if invitation
      @user = User.new(email: invitation.recipient_email, full_name: invitation.recipient_name)
      @invitation_token = invitation.token
      render :new
    else
      redirect_to expired_token_path
    end
  end

  private

  def handle_invitation
    if params[:invitation_token].present?
      invitation = Invitation.where(token: params[:invitation_token]).first
      invitation.inviter.follow(@user)
      @user.follow(invitation.inviter)
      invitation.update_column(:token, nil)
    end
  end

  def user_params
    params.require(:user).permit(:email, :password, :full_name)
  end
end
