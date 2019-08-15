module StripeWrapper
  class Charge
    def initialize

    end

    def self.create(options={})
      Stripe::Charge.create({
        amount: options[:amount],
        currency: 'usd',
        card: options[:card],
        description: options[:description]
      })
    end
  end
end

# begin
#   Stripe::Charge.create({
#     amount: 999,
#     currency: 'usd',
#     card: params[:stripeToken],
#     description: "Sign up charge for #{@user.email}"
#   })
# rescue Stripe::CardError => e
#   flash[:error] = e.message
#   render :new
# end
