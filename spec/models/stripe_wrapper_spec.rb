require 'spec_helper'

describe StripeWrapper do
  describe StripeWrapper::Charge do
    describe '.create' do
      it 'makes a successfull charge', :vcr do
        VCR.use_cassette('pay with stripe') do
          Stripe.api_key = ENV['STRIPE_SECRET_KEY']
          token = Stripe::Token.create({
            card: {
              number: '4242424242424242',
              exp_month: 6,
              exp_year: 2020,
              cvc: 314
            }
          }).id

          response = StripeWrapper::Charge.create({
            amount: 999,
            card: token,
            description: 'a valid charge'
          })
          expect(response.amount).to eq(999)
          expect(response.currency).to eq('usd')
        end 
      end
    end
  end
end
