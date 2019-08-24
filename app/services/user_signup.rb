class UserSignup
  attr_reader :error_message

  def initialize(user)
    @user = user
  end

  def sign_up(stripe_token, invitation_token)
    if @user.valid?
      handle_invitation(invitation_token)
      customer = StripeWrapper::Customer.create({
        user: @user,
        card: stripe_token
      })

      if customer.successful?
        @user.customer_token = customer.customer_token
        @user.save
        AppMailer.delay.send_welcome_email(@user.id)
        @status = :success
        self
      else
        @status = :failed
        @error_message = customer.error_message
        self
      end
    else
      @status = :failed
      @error_message = 'Invalid user information, please correct the errors.'
      self
    end
  end

  def successful?
    @status == :success
  end

  private

  # def handle_subscription(customer)
  #   StripeWrapper::Subscription.create({
  #     customer: customer.response.id
  #   })
  # end

  def handle_invitation(invitation_token)
    if invitation_token.present?
      invitation = Invitation.where(token: invitation_token).first
      invitation.inviter.follow(@user)
      @user.follow(invitation.inviter)
      invitation.update_column(:token, nil)
    end
  end
end
