require 'spec_helper'

describe StripeWrapper do
  describe StripeWrapper::Charge do
    describe '.create' do
      it 'makes a successfull charge', :vcr do
        VCR.use_cassette('pay with stripe') do
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
          expect(response).to be_successful
        end
      end

      it 'makes a card declined charge' do
        VCR.use_cassette('declined card') do
          token = Stripe::Token.create({
            card: {
              number: '4000000000000002',
              exp_month: 6,
              exp_year: 2020,
              cvc: 314
            }
          }).id

          response = StripeWrapper::Charge.create({
            amount: 999,
            card: token,
            description: 'an ivalid charge'
          })
          expect(response).not_to be_successful
        end
      end

      it 'returns the error message for a declined charge' do
        VCR.use_cassette('declined card') do
          token = Stripe::Token.create({
            card: {
              number: '4000000000000002',
              exp_month: 6,
              exp_year: 2020,
              cvc: 314
            }
          }).id

          response = StripeWrapper::Charge.create({
            amount: 999,
            card: token,
            description: 'an ivalid charge'
          })
          expect(response.error_message).to eq('Your card was declined.')
        end
      end
    end
  end
end
